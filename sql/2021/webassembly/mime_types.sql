select client, mimetype, count(0) as count
from `httparchive.almanac.wasm_stats`
where date = '2021-09-01'
group by client, mimetype
order by client, count desc
