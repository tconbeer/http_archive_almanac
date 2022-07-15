# standardSQL
# Core Web Vitals distribution by SSG
# 
# Note that this is an unweighted average of all sites per SSG.
# Performance of sites with millions of visitors as weighted the same as small sites.
select client, app, cdn, count(distinct url) as origins
from
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
        where date = '2021-07-01' and firsthtml
    )
join
    (
        select distinct _table_suffix as client, app, url
        from `httparchive.technologies.2021_07_01_*`
        where
            lower(category) = 'static site generator'
            or app = 'Next.js'
            or app = 'Nuxt.js'
    )
    using(client, url)
where cdn is not null
group by cdn, app, client
order by origins desc
