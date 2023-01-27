create temporary function numberofimages(images_string string)
returns int64
language js
as
    '''
try {
  return JSON.parse(images_string).filter( i => parseInt(i.approximateResourceWidth) > 1 && parseInt(i.approximateResourceWidth) > 1 ).length;
} catch {
  return 0;
}
'''
;

with
    numimgs as (
        select
            _table_suffix as client,
            numberofimages(
                json_query(
                    json_value(payload, '$._responsive_images'), '$.responsive-images'
                )
            ) as numberofimages
        from `httparchive.pages.2021_07_01_*`
    ),

    percentiles as (
        select
            client, approx_quantiles(numberofimages, 1000) as numberofimagespercentiles
        from numimgs
        group by client
    )

select
    client,
    percentile,
    numberofimagespercentiles[offset(percentile * 10)] as numberofimages
from percentiles, unnest([0, 10, 25, 50, 75, 90, 100]) as percentile
