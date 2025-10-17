select
    client,
    sum(size.code) / sum(size.total) as code_pct,
    sum(size.init) / sum(size.total) as init_pct,
    sum(size.descriptors) / sum(size.total) as descriptors_pct,
    sum(size.externals) / sum(size.total) as externals_pct,
    sum(size.types) / sum(size.total) as types_pct,
    sum(size.custom) / sum(size.total) as custom_pct
from `httparchive.almanac.wasm_stats`
where date = '2021-09-01'
group by client
order by client
