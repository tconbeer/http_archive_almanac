# standardSQL
# 08_17: CSP 'unsafe-inline' usage
select
    client,
    csp_count,
    unsafe_inline_count,
    defaultsrc_unsafe_inline_count,
    scriptsrc_unsafe_inline_count,
    stylesrc_unsafe_inline_count,
    total,
    round(csp_count * 100 / total, 2) as pct_csp,
    round(unsafe_inline_count * 100 / total, 2) as pct_unsafe_inline,
    round(
        defaultsrc_unsafe_inline_count * 100 / total, 2
    ) as pct_defaultsrc_unsafe_inline,
    round(
        scriptsrc_unsafe_inline_count * 100 / total, 2
    ) as pct_scriptsrc_unsafe_inline,
    round(stylesrc_unsafe_inline_count * 100 / total, 2) as pct_stylesrc_unsafe_inline
from
    (
        select
            client,
            count(0) as total,
            countif(
                regexp_contains(lower(respotherheaders), 'content-security-policy =')
            ) as csp_count,
            countif(
                regexp_contains(lower(respotherheaders), 'unsafe-inline')
            ) as unsafe_inline_count,
            countif(
                regexp_contains(
                    lower(
                        regexp_extract(
                            respotherheaders, r'(?i)\W?default-src?([^,|;]+)'
                        )
                    ),
                    'unsafe-inline'
                )
            ) as defaultsrc_unsafe_inline_count,
            countif(
                regexp_contains(
                    lower(
                        regexp_extract(respotherheaders, r'(?i)\W?script-src?([^,|;]+)')
                    ),
                    'unsafe-inline'
                )
            ) as scriptsrc_unsafe_inline_count,
            countif(
                regexp_contains(
                    lower(
                        regexp_extract(respotherheaders, r'(?i)\W?style-src?([^,|;]+)')
                    ),
                    'unsafe-inline'
                )
            ) as stylesrc_unsafe_inline_count
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and firsthtml
        group by client
    )
