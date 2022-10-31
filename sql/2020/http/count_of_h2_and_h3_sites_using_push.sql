# standardSQL
# Count of H2 and H3 Sites using Push
select
    client,
    http_version,
    count(distinct if(was_pushed, page, null)) as num_pages_with_push,
    count(distinct page) as total,
    count(distinct if(was_pushed, page, null)) / count(distinct page) as pct
from
    (
        select
            client,
            page,
            json_extract_scalar(payload, '$._protocol') as http_version,
            json_extract_scalar(payload, '$._was_pushed') = '1' as was_pushed
        from `httparchive.almanac.requests`
        where
            date = '2020-08-01'
            and (
                lower(json_extract_scalar(payload, '$._protocol')) like 'http/2'
                or lower(json_extract_scalar(payload, '$._protocol')) like '%quic%'
                or lower(json_extract_scalar(payload, '$._protocol')) like 'h3%'
                or lower(json_extract_scalar(payload, '$._protocol')) like 'http/3%'
            )
    )
group by client, http_version
