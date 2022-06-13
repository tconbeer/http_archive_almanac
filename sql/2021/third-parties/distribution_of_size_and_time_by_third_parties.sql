# standardSQL
# Distribution of third party requests size and time by category
with
    requests as (
        select
            _table_suffix as client,
            pageid as page,
            url,
            respbodysize as body_size,
            time
        from `httparchive.summary_requests.2021_07_01_*`
    ),

    third_party as (
        select domain, category, count(distinct page) as page_usage
        from `httparchive.almanac.third_parties` tp
        join requests r on net.host(r.url) = net.host(tp.domain)
        where date = '2021-07-01' and category != 'hosting'
        group by domain, category
        having page_usage >= 50
    ),

    base as (
        select client, category, body_size, time
        from requests
        inner join third_party on net.host(requests.url) = net.host(third_party.domain)
    )

select
    client,
    category,
    percentile,
    approx_quantiles(body_size, 1000) [offset (percentile * 10)] as body_size,
    approx_quantiles(time, 1000) [offset (percentile * 10)] as time  -- noqa: L010
from base, unnest(generate_array(1, 100)) as percentile
group by client, category, percentile
order by client, category, percentile
