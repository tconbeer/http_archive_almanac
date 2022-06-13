select
    percentile,
    client,
    approx_quantiles(raw_size, 1000) [offset (percentile * 10)] as raw_size,
    approx_quantiles(size.total, 1000) [offset (percentile * 10)] as size_total,
    approx_quantiles(size.total_br, 1000) [offset (percentile * 10)] as size_total_br,
    approx_quantiles(size.total_strip, 1000) [
        offset (percentile * 10)
    ] as size_total_strip,
    approx_quantiles(size.total_strip_br, 1000) [
        offset (percentile * 10)
    ] as size_total_strip_br,
    approx_quantiles(size.total_opt, 1000) [offset (percentile * 10)] as size_total_opt,
    approx_quantiles(size.total_opt_br, 1000) [
        offset (percentile * 10)
    ] as size_total_opt_br,
    approx_quantiles( (raw_size - size.total_br), 1000) [
        offset (percentile * 10)
    ] as br_savings,
    approx_quantiles( (size.total_br - size.total_strip_br), 1000) [
        offset (percentile * 10)
    ] as strip_br_savings,
    approx_quantiles( (size.total_strip_br - size.total_opt_br), 1000) [
        offset (percentile * 10)
    ] as opt_br_savings,
    approx_quantiles( (size.total_strip - size.total_opt), 1000) [
        offset (percentile * 10)
    ] as opt_savings
from `httparchive.almanac.wasm_stats`, unnest(generate_array(1, 100)) as percentile
where date = '2021-09-01'
group by percentile, client
order by percentile, client
