# standardSQL
# 18_01b: Distribution of page weight by resource type and client (2020).
select
    percentile,
    _table_suffix as client,
    approx_quantiles(
        bytestotal / 1024, 1000) [offset (percentile * 10)
    ] as total_kbytes,
    approx_quantiles(byteshtml / 1024, 1000) [offset (percentile * 10)] as html_kbytes,
    approx_quantiles(bytesjs / 1024, 1000) [offset (percentile * 10)] as js_kbytes,
    approx_quantiles(bytescss / 1024, 1000) [offset (percentile * 10)] as css_kbytes,
    approx_quantiles(bytesimg / 1024, 1000) [offset (percentile * 10)] as img_kbytes,
    approx_quantiles(
        bytesother / 1024, 1000) [offset (percentile * 10)
    ] as other_kbytes,
    approx_quantiles(
        byteshtmldoc / 1024, 1000) [offset (percentile * 10)
    ] as html_doc_kbytes,
    approx_quantiles(bytesfont / 1024, 1000) [offset (percentile * 10)] as font_kbytes
from
    `httparchive.summary_pages.2020_08_01_*`,

    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by client, percentile
