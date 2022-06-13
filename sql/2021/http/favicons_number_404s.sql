# standardSQL
# Number of favicons returning a 404
select
    client,
    countif(url like '%favicon.ico' and status = 404) as num_favicon_404s,
    countif(status = 404) as all404s,
    count(0) as total_requests,
    countif(url like '%favicon.ico' and status = 404) / countif(
        status = 404
    ) as favicon_404s_pct,
    countif(url like '%favicon.ico' and status = 404) / count(
        0
    ) as favicon_404s_pct_all_requests
from `httparchive.almanac.requests`
where date = '2021-07-01'
group by client
