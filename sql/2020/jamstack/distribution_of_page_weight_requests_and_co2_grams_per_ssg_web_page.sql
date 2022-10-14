# standardSQL
# Distribution of page weight, requests, and co2 grams per SSG web page
# https://gitlab.com/wholegrain/carbon-api-2-0/-/blob/b498ec3bb239536d3612c5f3d758f46e0d2431a6/includes/carbonapi.php
-- TODO: Investigate fetching from Green Web Foundation
CREATE TEMP FUNCTION
GREEN(url STRING) AS (FALSE);
CREATE TEMP FUNCTION
adjustDataTransfer(val INT64) AS (val * 0.75 + 0.02 * val * 0.25);
CREATE TEMP FUNCTION
energyConsumption(bytes FLOAT64) AS (bytes * 1.805 / 1073741824);
CREATE TEMP FUNCTION
getCo2Grid(energy FLOAT64) AS (energy * 475);
CREATE TEMP FUNCTION
getCo2Renewable(energy FLOAT64) AS (energy * 0.1008 * 33.4 + energy * 0.8992 * 475);
CREATE TEMP FUNCTION
CO2(url STRING, bytes INT64) AS (
  IF(
    GREEN(url),
    getCo2Renewable(energyConsumption(adjustDataTransfer(bytes))),
    getCo2Grid(energyConsumption(adjustDataTransfer(bytes)))
  )
);

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
