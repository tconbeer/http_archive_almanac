# standardSQL
# Pages that deploy at least one tracker from a certain category
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
    category,
    count(distinct page) as number_of_websites,
    total_websites,
    count(distinct page) / total_websites as pct_websites
from `httparchive.almanac.requests`
join
    whotracksme
    on (
        net.host(urlshort) = domain
        or ends_with(net.host(urlshort), concat('.', domain))
    )
join totals using(client)
-- third party
where date = '2021-07-01' and net.reg_domain(page) != net.reg_domain(urlshort)
group by client, category, total_websites
union all
select
    client,
    'any' as category,
    count(distinct page) as number_of_websites,
    total_websites,
    count(distinct page) / total_websites as pct_websites
from `httparchive.almanac.requests`
join
    whotracksme
    on (
        net.host(urlshort) = domain
        or ends_with(net.host(urlshort), concat('.', domain))
    )
join totals using(client)
-- third party
where date = '2021-07-01' and net.reg_domain(page) != net.reg_domain(urlshort)
group by client, total_websites
union all
select
    client,
    'any_tracker' as category,
    count(distinct page) as number_of_websites,
    total_websites,
    count(distinct page) / total_websites as pct_websites
from `httparchive.almanac.requests`
join
    whotracksme
    on (
        net.host(urlshort) = domain
        or ends_with(net.host(urlshort), concat('.', domain))
    )
join totals using(client)
where
    date = '2021-07-01'
    and net.reg_domain(page) != net.reg_domain(urlshort)  -- third party
    and (
        -- categories selected from https://whotracks.me/blog/tracker_categories.html
        whotracksme.category = 'advertising'
        or whotracksme.category = 'pornvertising'
        or whotracksme.category = 'site_analytics'
        or whotracksme.category = 'social_media'
    )
group by client, total_websites
order by client, number_of_websites desc
