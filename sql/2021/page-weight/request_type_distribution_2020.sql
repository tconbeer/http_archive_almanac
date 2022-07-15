# standardSQL
# 728.9Mib: Distribution of requests by resource type and client (2020)
select
    percentile,
    _table_suffix as client,
    approx_quantiles(reqtotal, 1000) [offset (percentile * 10)] as total_req,
    approx_quantiles(reqhtml, 1000) [offset (percentile * 10)] as html_req,
    approx_quantiles(reqjs, 1000) [offset (percentile * 10)] as js_req,
    approx_quantiles(reqcss, 1000) [offset (percentile * 10)] as css_req,
    approx_quantiles(reqimg, 1000) [offset (percentile * 10)] as img_req,
    approx_quantiles(reqjson, 1000) [offset (percentile * 10)] as json_req,
    approx_quantiles(reqother, 1000) [offset (percentile * 10)] as other_req,
    approx_quantiles(reqfont, 1000) [offset (percentile * 10)] as font_req
from
    `httparchive.summary_pages.2020_08_01_*`,

    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by client, percentile
