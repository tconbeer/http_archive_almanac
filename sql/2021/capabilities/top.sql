# standardSQL
CREATE TEMP FUNCTION getFuguAPIs(data STRING)
RETURNS ARRAY<STRING>
LANGUAGE js AS '''
const $ = JSON.parse(data);
return Object.keys($);
''';

select _table_suffix as client, url, count(distinct fuguapi) as fuguapis
from
    `httparchive.pages.2021_07_01_*`,
    unnest(getfuguapis(json_query(payload, '$."_fugu-apis"'))) as fuguapi
where json_query(payload, '$."_fugu-apis"') != '[]'
group by client, url
having count(distinct fuguapi) >= 1
order by fuguapis desc, url, client
limit 100
;
