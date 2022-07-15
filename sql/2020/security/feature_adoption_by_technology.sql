# standardSQL
# Adoption of features based on the technology that is used
select
    client,
    category,
    app,
    headername,
    count(distinct url) as total_pages_with_technology,
    count(distinct if(starts_with(url, 'https'), url, null)) as total_https_pages,
    count(
        distinct if(
            regexp_contains(respotherheaders, concat('(?i)', headername, ' ')),
            url,
            null
        )
    ) as freq,
    safe_divide(
        count(
            distinct if(
                regexp_contains(respotherheaders, concat('(?i)', headername, ' ')),
                url,
                null
            )
        ),
        count(distinct url)
    ) as pct,
    safe_divide(
        count(
            distinct if(
                regexp_contains(respotherheaders, concat('(?i)', headername, ' '))
                and starts_with(url, 'https'),
                url,
                null
            )
        ),
        count(distinct if(starts_with(url, 'https'), url, null))
    ) as pct_https
from
    (
        select
            t._table_suffix as client,
            category,
            app,
            respotherheaders,
            r.urlshort as url,
            firsthtml
        from `httparchive.summary_requests.2020_08_01_*` as r
        inner join
            `httparchive.technologies.2020_08_01_*` as t
            on r._table_suffix = t._table_suffix
            and r.urlshort = t.url
        where firsthtml
    ),
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
group by client, category, app, headername
having
    total_pages_with_technology >= 1000
    and category in unnest(
        [
            'Blogs',
            'CDN',
            'Web frameworks',
            'Programming languages',
            'CMS',
            'Ecommerce',
            'PaaS',
            'Security'
        ]
    )
    and pct >= 0.50
order by client, category, app, headername
