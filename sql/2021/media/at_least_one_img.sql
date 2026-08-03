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
    )

select
    client,
    countif(numberofimages > 0) as atleastonecount,
    count(0) as total,
    safe_divide(countif(numberofimages > 0), count(0)) as atleastonepct
from numimgs
group by client
