select client, any_value(url) as url, count(0) as count
from `httparchive.almanac.wasm_stats`
where date = '2021-09-01'
group by client, filename
order by count desc
