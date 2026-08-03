# standardSQL
create temp function getfuguapis(data string)
returns array<string>
language js
as '''
const $ = JSON.parse(data);
return Object.keys($);
'''
;

select
    _table_suffix as client,
    fuguapi,
    count(distinct url) as pages,
    total,
    count(distinct url) / total as pct,
    array_to_string(array_agg(distinct url limit 50), ' ') as sample_urls
from `httparchive.pages.2021_07_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    ) using (_table_suffix),
    unnest(getfuguapis(json_query(payload, '$."_fugu-apis"'))) as fuguapi
where json_query(payload, '$."_fugu-apis"') != '[]'
group by fuguapi, client, total
having count(distinct url) >= 10
order by pct desc, client
;
