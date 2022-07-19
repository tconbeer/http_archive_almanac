# standardSQL
# Percentage of H2 and H3 sites affected by CDN prioritization issues
select
    client,
    if(pages.cdn = '', 'Not using CDN', pages.cdn) as cdn,
    if(
        prioritization_status is not null, prioritization_status, 'Unknown'
    ) as prioritizes_correctly,
    count(0) as num_pages,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select date, client, protocol as http_version, url, _cdn_provider as cdn
        from `httparchive.almanac.requests`
        where
            date = '2021-07-01'
            and firsthtml
            and (
                lower(protocol) = 'http/2'
                or lower(protocol) like '%quic%'
                or lower(protocol) like 'h3%'
                or lower(protocol) = 'http/3'
            )
    ) as pages
left join `httparchive.almanac.h2_prioritization_cdns` using(cdn, date)
group by client, cdn, prioritizes_correctly
order by num_pages desc
