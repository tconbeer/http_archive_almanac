# standardSQL
# Percentage of H2 and H3 sites affected by CDN prioritization issues
select
    client,
    http_version,
    if(pages.cdn = '', 'Not using CDN', pages.cdn) as cdn,
    if(
        prioritization_status is not null, prioritization_status, 'Unknown'
    ) as prioritizes_correctly,
    count(0) as num_pages,
    round(count(0) / sum(count(0)) over (partition by client), 4) as pct
from
    (
        select
            date,
            client,
            json_extract_scalar(payload, '$._protocol') as http_version,
            url,
            _cdn_provider as cdn
        from `httparchive.almanac.requests`
        where
            date = '2020-08-01'
            and firsthtml
            and (
                lower(json_extract_scalar(payload, '$._protocol')) like 'http/2'
                or lower(json_extract_scalar(payload, '$._protocol')) like '%quic%'
                or lower(json_extract_scalar(payload, '$._protocol')) like 'h3%'
                or lower(json_extract_scalar(payload, '$._protocol')) like 'http/3%'
            )
    ) as pages
left join `httparchive.almanac.h2_prioritization_cdns` using(cdn, date)
group by client, http_version, cdn, prioritizes_correctly
order by num_pages desc
