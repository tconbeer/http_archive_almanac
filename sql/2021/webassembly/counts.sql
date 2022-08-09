select client, count(0) as total_count, count(distinct filename) as distinct_count
from `httparchive.almanac.wasm_stats`
where date = '2021-09-01'
group by client
order by client
