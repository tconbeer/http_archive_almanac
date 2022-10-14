CREATE TEMPORARY FUNCTION getSrcsetInfo(responsiveImagesJsonString STRING)
RETURNS ARRAY<STRUCT<imgURL STRING, approximateResourceWidth INT64, approximateResourceHeight INT64, aspectRatio NUMERIC, isPortrait BOOL, isLandscape BOOL, isSquare BOOL>>
LANGUAGE js AS '''
  const parsed = JSON.parse( responsiveImagesJsonString );
  if ( parsed && parsed.map ) {
    return parsed.map( d => {
      const aspectRatio = ( d.approximateResourceWidth > 0 && d.approximateResourceHeight > 0 ?
        Math.round( ( d.approximateResourceWidth / d.approximateResourceHeight ) * 1000 ) / 1000 : -1 );
      return {
        imgURL: d.url,
        approximateResourceWidth: Math.floor( d.approximateResourceWidth || 0 ),
        approximateResourceHeight: Math.floor( d.approximateResourceHeight || 0 ),
        aspectRatio: aspectRatio,
        isPortrait: aspectRatio < 1 && aspectRatio > 0,
        isLandscape: aspectRatio > 1,
        isSquare: aspectRatio == 1
      }
    });
  }
''';

with
    imgs as (
        select
            _table_suffix as client,
            url as pageurl,
            imgurl,
            approximateresourcewidth,
            approximateresourceheight,
            isportrait,
            islandscape,
            issquare
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(
                getsrcsetinfo(
                    json_query(
                        json_value(payload, '$._responsive_images'),
                        '$.responsive-images'
                    )
                )
            )
        where approximateresourcewidth > 1 and approximateresourceheight > 1
    ),

    counts_per_client as (
        select
            client,
            countif(isportrait) as portraits,
            countif(islandscape) as landscapes,
            countif(issquare) as squares,
            count(0) as numberofimagesperclient
        from imgs
        group by client
    )

select
    client,
    safe_divide(portraits, numberofimagesperclient) as percentportrait,
    safe_divide(landscapes, numberofimagesperclient) as percentlandscape,
    safe_divide(squares, numberofimagesperclient) as percentsquare,
    numberofimagesperclient
from counts_per_client
