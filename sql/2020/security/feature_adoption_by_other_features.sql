# standardSQL
# Analysis of how certain features influence the adoption of other features
select
    _table_suffix as client,
    headername,
    count(0) as total_pages,
    countif(
        regexp_contains(respotherheaders, concat('(?i)', headername, ' '))
    ) as total_with_header,
    safe_divide(
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' '))),
        count(0)
    ) as pct,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and starts_with(url, 'https')
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_https,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and regexp_contains(respotherheaders, '(?i)Content-Security-Policy ')
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_csp,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and regexp_contains(
                respotherheaders, '(?i)Content-Security-Policy-Report-Only '
            )
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_csp_report_only,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and regexp_contains(respotherheaders, '(?i)Cross-Origin-Embedder-Policy ')
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_coep,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and regexp_contains(respotherheaders, '(?i)Cross-Origin-Opener-Policy ')
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_coop,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and regexp_contains(respotherheaders, '(?i)Cross-Origin-Resource-Policy ')
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_corp,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and regexp_contains(respotherheaders, '(?i)Expect-CT ')
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_expectct,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and regexp_contains(respotherheaders, '(?i)Feature-Policy ')
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_featurep,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and regexp_contains(respotherheaders, '(?i)Permissions-Policy ')
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_permissionsp,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and regexp_contains(respotherheaders, '(?i)Referrer-Policy ')
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_referrerp,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and regexp_contains(respotherheaders, '(?i)Report-To ')
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_reportto,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and regexp_contains(respotherheaders, '(?i)Strict-Transport-Security ')
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_hsts,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and regexp_contains(respotherheaders, '(?i)X-Content-Type-Options ')
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_xcto,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and regexp_contains(respotherheaders, '(?i)X-Frame-Options ')
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_xfo,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, concat('(?i)', headername, ' ')
            ) and regexp_contains(respotherheaders, '(?i)X-XSS-Protection ')
        ),
        countif(regexp_contains(respotherheaders, concat('(?i)', headername, ' ')))
    ) as pct_header_and_xss
from
    `httparchive.summary_requests.2020_08_01_*`,
    unnest(
        [
            'Content-Security-Policy',
            'Content-Security-Policy-Report-Only',
            'Cross-Origin-Embedder-Policy',
            'Cross-Origin-Opener-Policy',
            'Cross-Origin-Resource-Policy',
            'Expect-CT',
            'Feature-Policy',
            'Permissions-Policy',
            'Referrer-Policy',
            'Report-To',
            'Strict-Transport-Security',
            'X-Content-Type-Options',
            'X-Frame-Options',
            'X-XSS-Protection'
        ]
    ) as headername
where firsthtml
group by client, headername
order by client, headername
