create temporary function getsrcsetinfo(responsiveimagesjsonstring string)
returns array < struct < imgurl string,
approximateresourcewidth int64,
approximateresourceheight int64,
aspectratio numeric,
resourceformat string
>>
language js
as '''
  const parsed = JSON.parse( responsiveImagesJsonString );
  if ( parsed && parsed.map ) {
    return parsed.map( d => ({
      imgURL: d.url,
      approximateResourceWidth: Math.floor( d.approximateResourceWidth || 0 ),
      approximateResourceHeight: Math.floor( d.approximateResourceHeight || 0 ),
      aspectRatio: ( d.approximateResourceWidth > 0 && d.approximateResourceHeight > 0 ?
        Math.round( ( d.approximateResourceWidth / d.approximateResourceHeight ) * 1000 ) / 1000 :
        -1 )
    }) );
  }
'''
;

with
    imgs as (
        select
            _table_suffix as client,
            url as pageurl,
            imgurl,
            approximateresourcewidth,
            approximateresourceheight,
            aspectratio
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
        select client, count(0) as numberofimagesperclient from imgs group by client
    ),

    counts_per_client_and_aspect_ratio as (
        select client, aspectratio, count(0) as numberofimagesperclientandaspectratio
        from imgs
        group by client, aspectratio
    )

select
    client,
    aspectratio,
    numberofimagesperclientandaspectratio,
    safe_divide(
        numberofimagesperclientandaspectratio, numberofimagesperclient
    ) as percentofimages
from counts_per_client_and_aspect_ratio
left join counts_per_client using(client)
order by percentofimages desc
