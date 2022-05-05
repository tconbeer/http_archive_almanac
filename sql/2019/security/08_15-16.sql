# standardSQL
# 08_15-16: Hash/nonce CSP directives
select
    client,
    csp_count,
    csp_script_sha_count,
    csp_script_nonce_count,
    total,
    round(csp_count * 100 / total, 2) as pct_csp,
    round(csp_script_sha_count * 100 / total, 2) as pct_csp_script_sha,
    round(csp_script_nonce_count * 100 / total, 2) as pct_csp_script_nonce
from
    (
        select
            client,
            count(0) as total,
            countif(
                regexp_contains(lower(respotherheaders), 'content-security-policy =')
            ) as csp_count,
            countif(
                regexp_contains(
                    lower(respotherheaders), 'content-security-policy ='
                ) and regexp_contains(
                    lower(
                        regexp_extract(respotherheaders, r'(?i)\W?script-src?([^,|;]+)')
                    ),
                    'sha256|sha384|sha512'
                )
            ) as csp_script_sha_count,
            countif(
                regexp_contains(
                    lower(respotherheaders), 'content-security-policy ='
                ) and regexp_contains(
                    lower(
                        regexp_extract(respotherheaders, r'(?i)\W?script-src?([^,|;]+)')
                    ),
                    'nonce-'
                )
            ) as csp_script_nonce_count
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and firsthtml
        group by client
    )
