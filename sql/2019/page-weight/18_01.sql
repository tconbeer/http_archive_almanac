# standardSQL
# 18_01: Distribution of page weight by resource type and client.
select
    percentile,
    _table_suffix as client,
    approx_quantiles(round(bytestotal / 1024, 2), 1000) [
        offset (percentile * 10)
    ] as total_kbytes,
    approx_quantiles(round(byteshtml / 1024, 2), 1000) [
        offset (percentile * 10)
    ] as html_kbytes,
    approx_quantiles(round(bytesjs / 1024, 2), 1000) [
        offset (percentile * 10)
    ] as js_kbytes,
    approx_quantiles(round(bytescss / 1024, 2), 1000) [
        offset (percentile * 10)
    ] as css_kbytes,
    approx_quantiles(round(bytesimg / 1024, 2), 1000) [
        offset (percentile * 10)
    ] as img_kbytes,
    approx_quantiles(round(bytesother / 1024, 2), 1000) [
        offset (percentile * 10)
    ] as other_kbytes,
    approx_quantiles(round(byteshtmldoc / 1024, 2), 1000) [
        offset (percentile * 10)
    ] as html_doc_kbytes
from
    `httparchive.summary_pages.2019_07_01_*`,
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by client, percentile
