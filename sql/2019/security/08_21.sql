# standardSQL
# 08_21: CSP 'upgrade-insecure-requests' usage
select
    client,
    csp_count,
    csp_upgrade_insecure_requests_count,
    total,
    round(csp_count * 100 / total, 2) as pct_csp,
    round(
        csp_upgrade_insecure_requests_count * 100 / total, 2
    ) as pct_csp_upgrade_insecure_requests
from
    (
        select
            client,
            count(0) as total,
            countif(
                regexp_contains(respotherheaders, r'(?i)\Wcontent-security-policy =')
            ) as csp_count,
            countif(
                regexp_contains(
                    lower(
                        regexp_extract(
                            respotherheaders, r'(?i)\Wcontent-security-policy =([^,]+)'
                        )
                    ),
                    'upgrade-insecure-requests'
                )
            ) as csp_upgrade_insecure_requests_count
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and firsthtml
        group by client
    )
