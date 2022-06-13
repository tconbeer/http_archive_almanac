# standardSQL
# HSTS includeSubDomains and preload usage
select
    client,
    count(0) as total_requests,
    countif(hsts_header_val is not null) as total_hsts_headers,
    countif(hsts_header_val is not null) / count(0) as pct_hsts_requests,
    countif(
        regexp_contains(
            hsts_header_val, r'(?i)max-age\s*=\s*\d+'
        ) and not regexp_contains(
            concat(hsts_header_val, ' '), r'(?i)max-age\s*=\s*0\W'
        )
    ) / countif(hsts_header_val is not null) as pct_valid_max_age,
    countif(
        regexp_contains(concat(hsts_header_val, ' '), r'(?i)max-age\s*=\s*0\W')
    ) / countif(hsts_header_val is not null) as pct_zero_max_age,
    countif(regexp_contains(hsts_header_val, r'(?i)includeSubDomains')) / countif(
        hsts_header_val is not null
    ) as pct_include_subdomains,
    countif(regexp_contains(hsts_header_val, r'(?i)preload')) / countif(
        hsts_header_val is not null
    ) as pct_preload
from
    (
        select
            client,
            regexp_extract(
                respotherheaders, r'(?i)strict-transport-security =([^,]+)'
            ) as hsts_header_val
        from `httparchive.almanac.requests`
        where date = '2020-08-01' and firsthtml
    )
group by client
