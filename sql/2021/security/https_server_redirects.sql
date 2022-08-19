# standardSQL
# Prevalence of server redirects from HTTP to HTTPS over Jan 2021 to Jul 2021
select
    client,
    date,
    count(distinct url) as total_urls_on_page,
    count(
        distinct(case when url like 'http://%' then url end)
    ) as count_http_urls_on_page,
    count(distinct(case when url like 'http://%' then url end))
    / count(distinct url) as pct_http_urls_on_page,
    count(
        distinct(
            case
                when
                    url like 'http://%'
                    and resp_location like 'https://%'
                    and status between 300 and 399
                then url
            end
        )
    ) as count_http_urls_with_https_redirect_on_page,
    count(
        distinct(
            case
                when
                    url like 'http://%'
                    and resp_location like 'https://%'
                    and status between 300 and 399
                then url
            end
        )
    ) / count(distinct(case when url like 'http://%' then url end)
    ) as pct_http_urls_with_https_redirect_on_page
from `httparchive.almanac.requests`
where '2021-01-01' <= date and date <= '2021-07-01'
group by client, date
order by client, date
