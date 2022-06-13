create temporary function getsrcsetdensities(payload string)
returns array < struct < currentsrcdensity int64,
srcsetcandidatedensities array
< float64
>>
>
language js
as '''
try {
  var $ = JSON.parse(payload);
  var responsiveImages = JSON.parse($._responsive_images);
  responsiveImages = responsiveImages['responsive-images'];

  return responsiveImages.map(({currentSrcDensity, srcsetCandidateDensities}) => ({
    currentSrcDensity,
    srcsetCandidateDensities: srcsetCandidateDensities.map(density => Math.round(density * 100) / 100)
  }));
} catch (e) {
  return [];
}
'''
;

select
    percentile,
    client,
    approx_quantiles(image.currentsrcdensity, 1000) [
        offset (percentile * 10)
    ] as currentsrcdensity,
    approx_quantiles(srcsetcandidatedensity, 1000) [
        offset (percentile * 10)
    ] as srcsetcandidatedensity
from
    (
        select _table_suffix as client, image
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(getsrcsetdensities(payload)) as image
    ),
    unnest(image.srcsetcandidatedensities) as srcsetcandidatedensity,
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
