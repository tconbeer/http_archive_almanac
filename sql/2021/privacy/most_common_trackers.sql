# standardSQL
# Pages that deploy a certain tracker (as defined by WhoTracks.me, i.e., one tracker
# can run on multiple domains)
create temp function istrackercategory(category string)
returns bool
as
    (
        category = 'advertising'
        or category = 'pornvertising'
        or category = 'site_analytics'
        or category = 'social_media'
    )
;

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
    tracker,
    category,
    tracker || ' (' || category || ')' as tracker_and_category,
    istrackercategory(category) as istracker,
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
join totals using (client)
where date = '2021-07-01' and net.reg_domain(page) != net.reg_domain(urlshort)  -- third party
group by client, tracker, category, istracker, total_websites
order by pct_websites desc, client
limit 1000
