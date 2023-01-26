# standardSQL
# Distribution of page weight, requests, and co2 grams per SSG web page
# https://gitlab.com/wholegrain/carbon-api-2-0/-/blob/b498ec3bb239536d3612c5f3d758f46e0d2431a6/includes/carbonapi.php
create temp function green(url string)
as (false)
;  -- TODO: Investigate fetching from Green Web Foundation
create temp function adjustdatatransfer(val int64)
as (val * 0.75 + 0.02 * val * 0.25)
;
create temp function energyconsumption(bytes float64)
as (bytes * 1.805 / 1073741824)
;
create temp function getco2grid(energy float64)
as (energy * 475)
;
create temp function getco2renewable(energy float64)
as (energy * 0.1008 * 33.4 + energy * 0.8992 * 475)
;
create temp function co2(url string, bytes int64)
as
    (
        if(
            green(url),
            getco2renewable(energyconsumption(adjustdatatransfer(bytes))),
            getco2grid(energyconsumption(adjustdatatransfer(bytes)))
        )
    )
;

select
    percentile,
    client,
    approx_quantiles(requests, 1000)[offset(percentile * 10)] as requests,
    round(
        approx_quantiles(bytes, 1000)[offset(percentile * 10)] / 1024 / 1024, 2
    ) as mbytes,
    approx_quantiles(co2grams, 1000)[offset(percentile * 10)] as co2grams
from
    (
        select
            _table_suffix as client,
            reqtotal as requests,
            bytestotal as bytes,
            co2(url, bytestotal) as co2grams
        from `httparchive.summary_pages.2020_08_01_*`
        join
            (
                select _table_suffix, url
                from `httparchive.technologies.2020_08_01_*`
                where
                    lower(category) = 'static site generator'
                    or app = 'Next.js'
                    or app = 'Nuxt.js'
                    or app = 'Docusaurus'
            ) using (_table_suffix, url)
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
