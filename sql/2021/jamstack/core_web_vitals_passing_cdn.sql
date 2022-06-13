# standardSQL
# Core Web Vitals performance by CMS
create temp function is_good(
    good float64, needs_improvement float64, poor float64
) returns bool as (good / (good + needs_improvement + poor) >= 0.75)
;

create temp function is_non_zero(
    good float64, needs_improvement float64, poor float64
) returns bool as (good + needs_improvement + poor > 0)
;


select
    client,
    cdn,
    count(distinct origin) as origins,
    # Origins with good LCP divided by origins with any LCP.
    safe_divide(
        count(distinct if(is_good(fast_lcp, avg_lcp, slow_lcp), origin, null)),
        count(distinct if(is_non_zero(fast_lcp, avg_lcp, slow_lcp), origin, null))
    ) as pct_good_lcp,

    # Origins with good FID divided by origins with any FID.
    safe_divide(
        count(distinct if(is_good(fast_fid, avg_fid, slow_fid), origin, null)),
        count(distinct if(is_non_zero(fast_fid, avg_fid, slow_fid), origin, null))
    ) as pct_good_fid,

    # Origins with good CLS divided by origins with any CLS.
    safe_divide(
        count(distinct if(is_good(small_cls, medium_cls, large_cls), origin, null)),
        count(distinct if(is_non_zero(small_cls, medium_cls, large_cls), origin, null))
    ) as pct_good_cls,

    # Origins with good LCP, FID, and CLS dividied by origins with any LCP, FID, and
    # CLS.
    safe_divide(
        count(
            distinct if(
                is_good(fast_lcp, avg_lcp, slow_lcp) and
                (
                    not is_non_zero(fast_fid, avg_fid, slow_fid) or is_good(
                        fast_fid, avg_fid, slow_fid
                    )
                ) and
                is_good(small_cls, medium_cls, large_cls),
                origin,
                null
            )
        ),
        count(
            distinct if(
                is_non_zero(fast_lcp, avg_lcp, slow_lcp) and
                is_non_zero(small_cls, medium_cls, large_cls),
                origin,
                null
            )
        )
    ) as pct_good_cwv
from
    (
        select
            if(device = 'desktop', 'desktop', 'mobile') as client,
            concat(origin, '/') as url,
            *
        from `chrome-ux-report.materialized.device_summary`
        where date = '2021-07-01'
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
                    ) = 'x-github-request'
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
                    ) = 'netlify'
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
                    ) is not null
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
                    ) is not null
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
                    ) is not null
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
                    ) is not null
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
    using
    (client, url)
join
    (
        select distinct _table_suffix as client, url
        from `httparchive.technologies.2021_07_01_*`
        where
            lower(
                category
            ) = 'static site generator' or app = 'Next.js' or app = 'Nuxt.js'
    )
    using(client, url)
where cdn is not null
group by cdn, client
order by origins desc
