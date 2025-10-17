# standardSQL
# Count of H2 and H3 Sites Grouped By Server
select
    client,
    json_extract_scalar(payload, '$._protocol') as http_version,
    # Omit server version
    normalize_and_casefold(
        regexp_extract(resp_server, r'\s*([^/]*)\s*')
    ) as server_header,
    count(0) as num_pages,
    sum(count(0)) over (partition by client) as total,
    round(count(0) / sum(count(0)) over (partition by client), 4) as pct
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
group by client, http_version, server_header
having num_pages >= 100
order by num_pages desc
