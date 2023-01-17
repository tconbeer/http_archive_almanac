# standardSQL
# 08_20: CSP 'trusted-types' usage
select
    client,
    csp_report_only_count,
    csp_trusted_type_count,
    csp_report_only_trusted_type_count,
    total,
    round(csp_report_only_count * 100 / total, 2) as pct_csp_report_only,
    round(csp_trusted_type_count * 100 / total, 2) as pct_csp_trusted_type,
    round(csp_trusted_type_count * 100 / total, 2) as pct_csp_report_only_trusted_type
from
    (
        select
            client,
            count(0) as total,
            countif(
                regexp_contains(
                    respotherheaders, r'(?i)\Wcontent-security-policy-report-only ='
                )
            ) as csp_report_only_count,
            countif(
                regexp_contains(
                    lower(
                        regexp_extract(
                            respotherheaders, r'(?i)\Wcontent-security-policy =([^,]+)'
                        )
                    ),
                    'trusted-types'
                )
            ) as csp_trusted_type_count,
            countif(
                regexp_contains(
                    lower(
                        regexp_extract(
                            respotherheaders,
                            r'(?i)\Wcontent-security-policy-report-only =([^,]+)'
                        )
                    ),
                    'trusted-types'
                )
            ) as csp_report_only_trusted_type_count
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and firsthtml
        group by client
    )
