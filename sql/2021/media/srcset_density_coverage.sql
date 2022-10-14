# standardSQL
# images srcset candidates average
CREATE TEMPORARY FUNCTION getSrcsetInfo(responsiveImagesJsonString STRING)
RETURNS ARRAY<STRUCT<
    hasSrcset BOOL,
    srcsetHasXDescriptors BOOL,
    srcsetHasWDescriptors BOOL,
    srcsetCandidateDensities ARRAY<FLOAT64>,
    numberOfSrcsetCandidates INT64,
    minDensity FLOAT64,
    maxDensity FLOAT64>>
LANGUAGE js AS '''
  const parsed = JSON.parse( responsiveImagesJsonString );
  if ( parsed && parsed.map ) {
    return parsed.map( d => {
      const result = {
          hasSrcset: d.hasSrcset,
          srcsetHasXDescriptors: d.srcsetHasXDescriptors,
          srcsetHasWDescriptors: d.srcsetHasXDescriptors,
          srcsetCandidateDensities: [],
          numberOfSrcsetCandidates: 0,
          minDensity: d.currentSrcDensity,
          maxDensity: d.currentSrcDensity
        };
      if ( d.srcsetCandidateDensities && d.srcsetCandidateDensities.map ) {
        const densities = d.srcsetCandidateDensities.map( n => parseFloat( n ) );
        result.srcsetCandidateDensities = densities;
        result.numberOfSrcsetCandidates = densities.length;
        result.minDensity = Math.min( ...densities );
        result.maxDensity = Math.max( ...densities );
        }
      return result;
    });
  }
''';

with
    imgs as (
        select
            _table_suffix as client,
            hassrcset,
            srcsetcandidatedensities,
            mindensity,
            maxdensity
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
        where srcsethasxdescriptors = true or srcsethaswdescriptors = true
    ),

    counts as (
        select
            client,
            count(0) as number_of_imgs_with_srcset,
            countif(
                mindensity <= 1 and maxdensity >= 1.5
            ) as number_of_srcsets_covering_1x_to_1p5x,
            countif(
                mindensity <= 1 and maxdensity >= 2
            ) as number_of_srcsets_covering_1x_to_2x,
            countif(
                mindensity <= 1 and maxdensity >= 2.5
            ) as number_of_srcsets_covering_1x_to_2p5x,
            countif(
                mindensity <= 1 and maxdensity >= 3
            ) as number_of_srcsets_covering_1x_to_3x
        from imgs
        group by client
    )

select
    client,
    number_of_imgs_with_srcset,
    number_of_srcsets_covering_1x_to_1p5x,
    number_of_srcsets_covering_1x_to_2x,
    number_of_srcsets_covering_1x_to_2p5x,
    number_of_srcsets_covering_1x_to_3x,
    number_of_srcsets_covering_1x_to_1p5x
    / number_of_imgs_with_srcset as pct_of_srcsets_covering_1x_to_1p5x,
    number_of_srcsets_covering_1x_to_2x
    / number_of_imgs_with_srcset as pct_of_srcsets_covering_1x_to_2x,
    number_of_srcsets_covering_1x_to_2p5x
    / number_of_imgs_with_srcset as pct_of_srcsets_covering_1x_to_2p5x,
    number_of_srcsets_covering_1x_to_3x
    / number_of_imgs_with_srcset as pct_of_srcsets_covering_1x_to_3x
from counts
