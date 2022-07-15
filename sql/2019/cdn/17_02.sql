# standardSQL
# 17_02: Percentage of the sites which use a CDN for any resource
select
    client,
    countif(firsthtml) as htmlhits,
    countif(not firsthtml and samehost) as domainhits,
    countif(not samehost and samedomain) as subdomainhits,
    countif(not samehost and not samedomain) as thirdpartyhits,
    count(0) as hits,
    sum(if(firsthtml, respbodysize, 0)) as htmlbytes,
    sum(if(not firsthtml and samehost, respbodysize, 0)) as domainbytes,
    sum(if(not samehost and samedomain, respbodysize, 0)) as subdomainbytes,
    sum(if(not samehost and not samedomain, respbodysize, 0)) as thirdpartybytes,
    sum(respbodysize) as bytes,

    countif(cdn != 'ORIGIN') as cdnhits,
    round( (countif(cdn != 'ORIGIN') * 100) / count(0), 2) as hitspct,
    sum(case when cdn != 'ORIGIN' then respbodysize else 0 end) as cdnbytes,
    round(
        (sum(case when _cdn_provider != '' then respbodysize else 0 end) * 100) / sum(
            respbodysize
        ),
        2
    ) as bytespct
from
    (
        select
            client,
            page,
            url,
            firsthtml,
            respbodysize,
            ifnull(
                nullif(regexp_extract(_cdn_provider, r'^([^,]*).*'), ''), 'ORIGIN'
            ) as cdn,
            case
                when net.host(url) = net.host(page) then true else false
            end as samehost,
            # if toplevel reg_domain will return NULL so we group this as sameDomain
            case
                when
                    net.host(url) = net.host(page)
                    or net.reg_domain(url) = net.reg_domain(page)
                then true
                else false
            end as samedomain
        from `httparchive.almanac.requests3`
    -- GROUP BY client, pageid, requestid, page, url, firstHtml, _cdn_provider,
    -- respBodySize
    )
group by client, hits
