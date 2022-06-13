select client, resp_content_encoding, count(0) as count
from `httparchive.almanac.wasm_stats`
where date = '2021-09-01'
group by client, resp_content_encoding
order by client, count desc
