# standardSQL
# Security feature adoption grouped by sites frequently visited from different
# countries
CREATE TEMP FUNCTION getNumSecurityHeaders(headers STRING) AS (
  (
    SELECT
      COUNTIF(REGEXP_CONTAINS(headers, CONCAT('(?i)', headername, ' ')))
    FROM
      UNNEST(['Content-Security-Policy', 'Content-Security-Policy-Report-Only', 'Cross-Origin-Embedder-Policy', 'Cross-Origin-Opener-Policy',
              'Cross-Origin-Resource-Policy', 'Expect-CT', 'Feature-Policy', 'Permissions-Policy', 'Referrer-Policy', 'Report-To',
              'Strict-Transport-Security', 'X-Content-Type-Options', 'X-Frame-Options', 'X-XSS-Protection']) AS headername
  )
);

select
    client,
    country,
    count(0) as total_pages_for_country,
    countif(starts_with(url, 'https')) as freq_https,
    safe_divide(countif(starts_with(url, 'https')), count(0)) as pct_https,
    safe_divide(
        countif(regexp_contains(respotherheaders, '(?i)X-Frame-Options ')), count(0)
    ) as pct_xfo,
    safe_divide(
        countif(regexp_contains(respotherheaders, '(?i)Strict-Transport-Security ')),
        count(0)
    ) as pct_hsts,
    safe_divide(
        countif(regexp_contains(respotherheaders, '(?i)X-Content-Type-Options ')),
        count(0)
    ) as pct_xcto,
    safe_divide(
        countif(regexp_contains(respotherheaders, '(?i)Expect-CT ')), count(0)
    ) as pct_expectct,
    safe_divide(
        countif(regexp_contains(respotherheaders, '(?i)Content-Security-Policy ')),
        count(0)
    ) as pct_csp,
    safe_divide(
        countif(
            regexp_contains(
                respotherheaders, '(?i)Content-Security-Policy-Report-Only '
            )
        ),
        count(0)
    ) as pct_csp,
    safe_divide(
        countif(regexp_contains(respotherheaders, '(?i)X-XSS-Protection ')), count(0)
    ) as pct_xss,
    avg(getnumsecurityheaders(respotherheaders)) as avg_security_headers,
    approx_quantiles(getnumsecurityheaders(respotherheaders), 1000)[
        offset(500)
    ] as median_security_headers
from
    (
        select
            r._table_suffix as client,
            `chrome-ux-report.experimental`.get_country(country_code) as country,
            respotherheaders,
            r.urlshort as url,
            firsthtml
        from `httparchive.summary_requests.2021_07_01_*` as r
        inner join
            `httparchive.summary_pages.2021_07_01_*` as p
            on r._table_suffix = p._table_suffix
            and r.pageid = p.pageid
        inner join
            `chrome-ux-report.experimental.country` as c
            on p.url = concat(c.origin, '/')
        where firsthtml and yyyymm = 202107
    )
group by client, country
order by client, total_pages_for_country desc
