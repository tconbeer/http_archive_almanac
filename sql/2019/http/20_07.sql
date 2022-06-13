# standardSQL
# 20.07 - % of sites affected by CDN prioritization issues (H2 and served by CDN)
select
    client,
    if(pages.cdn = '', 'Not using CDN', pages.cdn) as cdn,
    if(
        prioritization_status is not null, prioritization_status, 'Unknown'
    ) as prioritizes_correctly,
    count(0) as num_pages,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from
    (
        select date, client, url, json_extract_scalar(payload, '$._cdn_provider') as cdn
        from `httparchive.almanac.requests`
        where
            date = '2019-07-01' and json_extract_scalar(
                payload, '$._protocol'
            ) = 'HTTP/2' and firsthtml
    ) as pages
left join
    `httparchive.almanac.h2_prioritization_cdns` as h2_pri
    on pages.date = h2_pri.date
    and pages.cdn = h2_pri.cdn
group by client, cdn, prioritizes_correctly
order by num_pages desc
