# standardSQL
select
    _table_suffix as client,
    substring(url, 1, 400) as url,
    respheaderssize / 1024 as respheaderssizekib
from `httparchive.summary_requests.2021_07_01_*`
where respheaderssize is not null
order by respheaderssizekib desc
limit 200
