# standardSQL
# Determines to what extent the top-N technology drivers are responsible for the
# global adoption of different security features
-- from https://stackoverflow.com/a/54835472
create temp function array_slice(arr array<string>, start int64, finish int64)
returns array<string>
as
    (
        array(
            select part
            from unnest(arr) part
            with
            offset as index
            where index between start and finish
            order by index
        )
    )
;

with
    app_headers as (
        select
            t._table_suffix as client,
            headername,
            category,
            app,
            respotherheaders,
            t.url as url
        from `httparchive.summary_requests.2020_08_01_*` as r
        inner join
            `httparchive.technologies.2020_08_01_*` as t
            on r._table_suffix = t._table_suffix
            and r.urlshort = t.url,
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
        where
            firsthtml
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
    )

select
    client,
    headername,
    topn,
    array_to_string(array_slice(top_apps, 0, topn - 1), ', ', 'NULL') as topn_apps,
    count(
        distinct if(
            regexp_contains(respotherheaders, concat('(?i)', headername, ' '))
            and concat(category, '_', app)
            in unnest(array_slice(top_apps, 0, topn - 1)),
            url,
            null
        )
    ) as freq_in_topn,
    safe_divide(
        count(
            distinct if(
                regexp_contains(respotherheaders, concat('(?i)', headername, ' '))
                and concat(category, '_', app)
                in unnest(array_slice(top_apps, 0, topn - 1)),
                url,
                null
            )
        ),
        global_freq
    ) as pct_overall
from app_headers
inner join
    (
        select
            headername,
            client,
            array_agg(concat(category, '_', app) order by freq desc) as top_apps
        from
            (
                select
                    headername,
                    client,
                    category,
                    app,
                    count(
                        distinct if(
                            regexp_contains(
                                respotherheaders, concat('(?i)', headername, ' ')
                            ),
                            url,
                            null
                        )
                    ) as freq,
                    safe_divide(
                        count(
                            distinct if(
                                regexp_contains(
                                    respotherheaders, concat('(?i)', headername, ' ')
                                ),
                                url,
                                null
                            )
                        ),
                        count(distinct url)
                    ) as pct
                from app_headers
                group by headername, client, category, app
                having pct > 0.8 and freq > 1000
            )
        group by client, headername
    ) using (client, headername)
inner join
    (
        select
            client,
            headername,
            count(
                distinct if(
                    regexp_contains(respotherheaders, concat('(?i)', headername, ' ')),
                    url,
                    null
                )
            ) as global_freq
        from app_headers
        group by client, headername
    ) using (client, headername),
    unnest(generate_array(1, 10)) as topn
group by client, topn, topn_apps, headername, global_freq
order by client, headername, topn
