# standardSQL
# Core Web Vitals distribution by SSG
# 
# Note that this is an unweighted average of all sites per SSG.
# Performance of sites with millions of visitors as weighted the same as small sites.
select
    app,
    cdn,
    client,
    count(distinct origin) as origins,
    sum(fast_lcp) / (sum(fast_lcp) + sum(avg_lcp) + sum(slow_lcp)) as good_lcp,
    sum(avg_lcp) / (sum(fast_lcp) + sum(avg_lcp) + sum(slow_lcp)) as ni_lcp,
    sum(slow_lcp) / (sum(fast_lcp) + sum(avg_lcp) + sum(slow_lcp)) as poor_lcp,

    sum(fast_fid) / (sum(fast_fid) + sum(avg_fid) + sum(slow_fid)) as good_fid,
    sum(avg_fid) / (sum(fast_fid) + sum(avg_fid) + sum(slow_fid)) as ni_fid,
    sum(slow_fid) / (sum(fast_fid) + sum(avg_fid) + sum(slow_fid)) as poor_fid,

    sum(small_cls) / (sum(small_cls) + sum(medium_cls) + sum(large_cls)) as good_cls,
    sum(medium_cls) / (sum(small_cls) + sum(medium_cls) + sum(large_cls)) as ni_cls,
    sum(large_cls) / (sum(small_cls) + sum(medium_cls) + sum(large_cls)) as poor_cls
from
    (
        select
            if(device = 'desktop', 'desktop', 'mobile') as client,
            concat(origin, '/') as url,
            *
        from `chrome-ux-report.materialized.device_summary`
        where date = '2020-08-01'
    )
join
    (
        select
            case
                when
                    regexp_extract(
                        lower(
                            concat(
                                respotherheaders,
                                resp_x_powered_by,
                                resp_via,
                                resp_server
                            )
                        ),
                        '(x-github-request)'
                    )
                    = 'x-github-request'
                then 'GitHub'
                when
                    regexp_extract(
                        lower(
                            concat(
                                respotherheaders,
                                resp_x_powered_by,
                                resp_via,
                                resp_server
                            )
                        ),
                        '(netlify)'
                    )
                    = 'netlify'
                then 'Netlify'
                when
                    regexp_extract(
                        lower(
                            concat(
                                respotherheaders,
                                resp_x_powered_by,
                                resp_via,
                                resp_server
                            )
                        ),
                        '(x-nf-request-id)'
                    )
                    is not null
                then 'Netlify'
                when
                    regexp_extract(
                        lower(
                            concat(
                                respotherheaders,
                                resp_x_powered_by,
                                resp_via,
                                resp_server
                            )
                        ),
                        '(x-vercel-id)'
                    )
                    is not null
                then 'Vercel'
                when
                    regexp_extract(
                        lower(
                            concat(
                                respotherheaders,
                                resp_x_powered_by,
                                resp_via,
                                resp_server
                            )
                        ),
                        '(x-amz-cf-id)'
                    )
                    is not null
                then 'AWS'
                when
                    regexp_extract(
                        lower(
                            concat(
                                respotherheaders,
                                resp_x_powered_by,
                                resp_via,
                                resp_server
                            )
                        ),
                        '(x-azure-ref)'
                    )
                    is not null
                then 'Azure'
                when _cdn_provider = 'Microsoft Azure'
                then 'Azure'
                when _cdn_provider = 'DigitalOcean Spaces CDN'
                then 'DigitalOcean'
                when _cdn_provider = 'Vercel'
                then 'Vercel'
                when _cdn_provider = 'Amazon CloudFront'
                then 'AWS'
                when _cdn_provider = 'Akamai'
                then 'Akamai'
                when _cdn_provider = 'Cloudflare'
                then 'Cloudflare'
                else null
            end as cdn,
            client,
            page as url
        from `httparchive.almanac.requests`
        where date = '2020-08-01' and firsthtml
    )
    using
    (client, url)
join
    (
        select _table_suffix as client, app, url
        from `httparchive.technologies.2020_08_01_*`
        where
            lower(category) = 'static site generator'
            or app = 'Next.js'
            or app = 'Nuxt.js'
            or app = 'Docusaurus'
    )
    using(client, url)
where cdn is not null
group by app, cdn, client
order by origins desc
