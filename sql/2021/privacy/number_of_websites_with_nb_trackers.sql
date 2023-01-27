# standardSQL
# Number of websites that deploy a certain number of trackers
with
    whotracksme as (
        select domain, category, tracker
        from `httparchive.almanac.whotracksme`
        where date = '2021-07-01'
    ),

    totals as (
        select client, count(distinct page) as total_websites
        from `httparchive.almanac.requests`
        where date = '2021-07-01'
        group by client
    )

select
    client,
    'any' as type,
    number_of_trackers,
    count(distinct page) as number_of_websites,
    total_websites,
    count(distinct page) / total_websites as pct_websites
from
    (
        select client, page, count(distinct tracker) as number_of_trackers
        from `httparchive.almanac.requests`
        join
            whotracksme
            on (
                net.host(urlshort) = domain
                or ends_with(net.host(urlshort), concat('.', domain))
            )
        where date = '2021-07-01' and net.reg_domain(page) != net.reg_domain(urlshort)  -- third party
        group by client, page
    )
join totals using (client)
group by client, number_of_trackers, total_websites
union all
select
    client,
    'any_tracker' as type,
    number_of_trackers,
    count(distinct page) as number_of_websites,
    total_websites,
    count(distinct page) / total_websites as pct_websites
from
    (
        select client, page, count(distinct tracker) as number_of_trackers
        from `httparchive.almanac.requests`
        join
            whotracksme
            on (
                net.host(urlshort) = domain
                or ends_with(net.host(urlshort), concat('.', domain))
            )
        where
            date = '2021-07-01'
            and net.reg_domain(page) != net.reg_domain(urlshort)  -- third party
            and (
                -- categories selected from
                -- https://whotracks.me/blog/tracker_categories.html
                whotracksme.category = 'advertising'
                or whotracksme.category = 'pornvertising'
                or whotracksme.category = 'site_analytics'
                or whotracksme.category = 'social_media'
            )
        group by client, page
    )
join totals using (client)
group by client, number_of_trackers, total_websites
order by client, type, number_of_trackers
