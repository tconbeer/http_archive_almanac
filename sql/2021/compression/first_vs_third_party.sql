# standardSQL
# first_vs_third_party.sql : content encoding summary by party
select
    client,
    if(
        net.host(url) in (
            select domain
            from `httparchive.almanac.third_parties`
            where date = '2021-07-01' and category != 'hosting'
        ),
        'third party',
        'first party'
    ) as party,
    resp_content_encoding,
    count(0) as num_requests,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from `httparchive.almanac.requests`
where date = '2021-07-01'
group by client, party, resp_content_encoding
order by num_requests desc
