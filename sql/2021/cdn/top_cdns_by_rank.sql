# standardSQL
# top_cdns_by_rank.sql: Top CDNs used on the root HTML pages by CrUX rank
select
    client,
    nested_rank,
    cdn,
    countif(firsthtml) as firsthtmlhits,
    sum(countif(firsthtml)) over (partition by client) as firsthtmltotalhits,
    safe_divide(
        countif(firsthtml), sum(countif(firsthtml)) over (partition by client)
    ) as firsthtmlhitspct,

    countif(not firsthtml and not samehost and samedomain) as subdomainhits,
    sum(countif(not firsthtml and not samehost and samedomain)) over (
        partition by client
    ) as subdomaintotalhits,
    safe_divide(
        countif(not firsthtml and not samehost and samedomain),
        sum(countif(not firsthtml and not samehost and samedomain)) over (
            partition by client
        )
    ) as subdomainhitspct,

    countif(not firsthtml and not samehost and not samedomain) as thirdpartyhits,
    sum(countif(not firsthtml and not samehost and not samedomain)) over (
        partition by client
    ) as thirdpartytotalhits,
    safe_divide(
        countif(not firsthtml and not samehost and not samedomain),
        sum(countif(not firsthtml and not samehost and not samedomain)) over (
            partition by client
        )
    ) as thirdpartyhitspct,

    count(0) as hits,
    sum(count(0)) over (partition by client) as totalhits,
    safe_divide(count(0), sum(count(0)) over (partition by client)) as hitspct
from
    (
        select
            client,
            rank,
            page,
            url,
            firsthtml,
            respbodysize,
            # sometimes _cdn provider detection includes multiple entries. we bias for
            # the DNS detected entry which is the first entry
            ifnull(
                nullif(regexp_extract(_cdn_provider, r'^([^,]*).*'), ''), 'ORIGIN'
            ) as cdn,
            net.host(url) = net.host(page) as samehost,
            # if toplevel reg_domain will return NULL so we group this as sameDomain
            net.host(url) = net.host(page) or net.reg_domain(url) = net.reg_domain(
                page
            ) as samedomain
        from `httparchive.almanac.requests`
        where date = '2021-07-01'
    ),
    unnest( [1000, 10000, 100000, 1000000, 10000000]) as nested_rank
where rank <= nested_rank
group by client, nested_rank, cdn
order by client desc, nested_rank, firsthtmlhits desc
