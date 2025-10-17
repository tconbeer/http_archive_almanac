# standardSQL
# 08_18: CSP 'unsafe-eval' usage
select
    client,
    csp_count,
    unsafe_eval_count,
    defaultsrc_unsafe_eval_count,
    scriptsrc_unsafe_eval_count,
    stylesrc_unsafe_eval_count,
    total,
    round(csp_count * 100 / total, 2) as pct_csp,
    round(unsafe_eval_count * 100 / total, 2) as pct_unsafe_eval,
    round(defaultsrc_unsafe_eval_count * 100 / total, 2) as pct_defaultsrc_unsafe_eval,
    round(scriptsrc_unsafe_eval_count * 100 / total, 2) as pct_scriptsrc_unsafe_eval,
    round(stylesrc_unsafe_eval_count * 100 / total, 2) as pct_stylesrc_unsafe_eval
from
    (
        select
            client,
            count(0) as total,
            countif(
                regexp_contains(lower(respotherheaders), 'content-security-policy =')
            ) as csp_count,
            countif(
                regexp_contains(lower(respotherheaders), 'unsafe-eval')
            ) as unsafe_eval_count,
            countif(
                regexp_contains(
                    lower(
                        regexp_extract(
                            respotherheaders, r'(?i)\W?default-src?([^,|;]+)'
                        )
                    ),
                    'unsafe-eval'
                )
            ) as defaultsrc_unsafe_eval_count,
            countif(
                regexp_contains(
                    lower(
                        regexp_extract(respotherheaders, r'(?i)\W?script-src?([^,|;]+)')
                    ),
                    'unsafe-eval'
                )
            ) as scriptsrc_unsafe_eval_count,
            countif(
                regexp_contains(
                    lower(
                        regexp_extract(respotherheaders, r'(?i)\W?style-src?([^,|;]+)')
                    ),
                    'unsafe-eval'
                )
            ) as stylesrc_unsafe_eval_count
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and firsthtml
        group by client
    )
