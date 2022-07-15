# standardSQL
# 08_19: CSP 'strict-dynamic' usage
select
    client,
    csp_count,
    strict_dynamic_count,
    scriptsrc_strict_dynamic_count,
    defaultsrc_strict_dynamic_count,
    total,
    round(csp_count * 100 / total, 2) as pct_csp,
    round(strict_dynamic_count * 100 / total, 2) as pct_strict_dynamic,
    round(
        scriptsrc_strict_dynamic_count * 100 / total, 2
    ) as pct_scriptsrc_strict_dynamic,
    round(
        defaultsrc_strict_dynamic_count * 100 / total, 2
    ) as pct_defaultsrc_strict_dynamic
from
    (
        select
            client,
            count(0) as total,
            countif(
                regexp_contains(lower(respotherheaders), 'content-security-policy =')
            ) as csp_count,
            countif(
                regexp_contains(lower(respotherheaders), 'content-security-policy =')
                and regexp_contains(lower(respotherheaders), 'strict-dynamic')
            ) as strict_dynamic_count,
            countif(
                regexp_contains(lower(respotherheaders), 'content-security-policy =')
                and regexp_contains(
                    lower(
                        regexp_extract(respotherheaders, r'(?i)\W?script-src?([^,|;]+)')
                    ),
                    'strict-dynamic'
                )
            ) as scriptsrc_strict_dynamic_count,
            countif(
                regexp_contains(lower(respotherheaders), 'content-security-policy =')
                and regexp_contains(
                    lower(
                        regexp_extract(
                            respotherheaders, r'(?i)\W?default-src?([^,|;]+)'
                        )
                    ),
                    'strict-dynamic'
                )
            ) as defaultsrc_strict_dynamic_count
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and firsthtml
        group by client
    )
