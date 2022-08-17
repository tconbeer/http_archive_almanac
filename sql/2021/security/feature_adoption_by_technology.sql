# standardSQL
# Adoption of features based on the technology that is used
with
    totals as (
        select
            _table_suffix as client,
            category,
            app,
            count(url) as total_pages_with_technology,
            count(
                distinct if(starts_with(url, 'https'), url, null)
            ) as total_https_pages
        from `httparchive.technologies.2021_07_01_*`
        group by client, category, app
    )

select
    client,
    category,
    app,
    headername,
    total_pages_with_technology,
    total_https_pages,
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
        total_pages_with_technology
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
        total_https_pages
    ) as pct_https
from
    (
        select
            total_pages_with_technology,
            total_https_pages,
            t._table_suffix as client,
            t.category,
            t.app,
            respotherheaders,
            r.urlshort as url,
            firsthtml
        from `httparchive.summary_requests.2021_07_01_*` as r
        inner join
            `httparchive.summary_pages.2021_07_01_*` as p
            on r._table_suffix = p._table_suffix
            and r.pageid = p.pageid
        inner join
            `httparchive.technologies.2021_07_01_*` as t
            on p._table_suffix = t._table_suffix
            and p.urlshort = t.url
        inner join
            totals
            on t._table_suffix = totals.client
            and t.category = totals.category
            and t.app = totals.app
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
group by
    client, category, app, headername, total_pages_with_technology, total_https_pages
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
