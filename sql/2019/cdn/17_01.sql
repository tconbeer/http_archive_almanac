# standardSQL
# 17_01: Top CDNs used on the root HTML pages
select
    client,
    cdn,
    countif(firsthtml) as firsthtmlhits,
    countif(not firsthtml and not samehost and samedomain) as subdomainhits,
    countif(not firsthtml and not samehost and not samedomain) as thirdpartyhits,
    count(0) as hits,
    sum(countif(firsthtml)) over (partition by client) as firsthtmltotalhits,
    round(
        (
            countif(firsthtml) * 100 / (
                0.001 + sum(countif(firsthtml)) over (partition by client)
            )
        ),
        2
    ) as firsthtmlhitspct,
    sum(countif(not firsthtml and not samehost and samedomain)) over (
        partition by client
    ) as subdomaintotalhits,
    round(
        (
            countif(not firsthtml and not samehost and samedomain) * 100 / (
                0.001 + sum(
                    countif(not firsthtml and not samehost and samedomain)
                ) over (partition by client)
            )
        ),
        2
    ) as subdomainhitspct,
    sum(countif(not firsthtml and not samehost and not samedomain)) over (
        partition by client
    ) as thirdpartytotalhits,
    round(
        (
            countif(not firsthtml and not samehost and not samedomain) * 100 / (
                0.001 + sum(
                    countif(not firsthtml and not samehost and not samedomain)
                ) over (partition by client)
            )
        ),
        2
    ) as thirdpartyhitspct,
    sum(count(0)) over (partition by client) as totalhits,
    round(
        (count(0) * 100 / (0.001 + sum(count(0)) over (partition by client))), 2
    ) as hitspct
from
    (
        select
            client,
            page,
            url,
            firsthtml,
            respbodysize,
            # sometimes _cdn provider detection includes multiple entries. we bias for
            # the DNS detected entry which is the first entry
            ifnull(
                nullif(regexp_extract(_cdn_provider, r'^([^,]*).*'), ''), 'ORIGIN'
            ) as cdn,
            if(net.host(url) = net.host(page), true, false) as samehost,
            # if toplevel reg_domain will return NULL so we group this as sameDomain
            if(
                net.host(url) = net.host(page) or net.reg_domain(url) = net.reg_domain(
                    page
                ),
                true,
                false
            ) as samedomain
        from `httparchive.almanac.requests3`
    )
group by client, cdn
order by client desc, firsthtmlhits desc
