# standardSQL
# 08_13: mixed content
select
    client,
    countif(mixed_count > 0) as mixed_content_sites,
    countif(active_mixed_count > 0) as active_mixed_content_sites,
    count(0) as total,
    round(countif(mixed_count > 0) * 100 / count(0), 2) as pct_mixed,
    round(countif(active_mixed_count > 0) * 100 / count(0), 2) as pct_active_mixed
from
    (
        select
            client,
            countif(starts_with(url, 'http:')) as mixed_count,
            countif(
                starts_with(url, 'http:') and type in ('script', 'css', 'font')
            ) as active_mixed_count
        from `httparchive.almanac.summary_requests`
        where date = '2019-07-01' and starts_with(page, 'https') and status = 200
        group by client, page
    )
group by client
