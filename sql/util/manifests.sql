select distinct date, client, page, url, body
from
    (
        select *
        from `httparchive.almanac.summary_response_bodies`
        where date = '2020-08-01'
    )
join
    (
        select date, client, pwa_url as page, manifest_url as url
        from `httparchive.almanac.pwa_candidates`
        where date = '2020-08-01'
        group by date, client, page, url
    ) using (date, client, page, url)
