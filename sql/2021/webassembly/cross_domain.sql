select
    client,
    countif(net.reg_domain(page) != net.reg_domain(url)) / count(0) as cross_origin_pct
from `httparchive.almanac.wasm_stats`
where date = '2021-09-01'
group by client
order by client
