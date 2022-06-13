# standardSQL
select
    substr(_table_suffix, 0, 10) as date,
    if(ends_with(_table_suffix, 'desktop'), 'desktop', 'mobile') as client,
    count(distinct if(lower(attr) = '"lazy"', url, null)) / count(
        distinct url
    ) as percent
from `httparchive.pages.*`
left join
    unnest(
        json_extract_array(json_extract_scalar(payload, "$['_img-loading-attr']"), '$')
    ) as attr
group by date, client
order by date desc, client
