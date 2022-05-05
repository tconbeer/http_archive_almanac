# standardSQL
# 07_13: Distribution of TLS Certificate SAN size
select
    client,
    cdn,
    firsthtml,
    count(0) as requests,
    approx_quantiles(sanlength, 1000) [offset (100)] as p10,
    approx_quantiles(sanlength, 1000) [offset (250)] as p25,
    approx_quantiles(sanlength, 1000) [offset (500)] as p50,
    approx_quantiles(sanlength, 1000) [offset (750)] as p75,
    approx_quantiles(sanlength, 1000) [offset (900)] as p90
from
    (
        select
            client,
            requestid,
            page,
            url,
            firsthtml,
            # sometimes _cdn provider detection includes multiple entries. we bias for
            # the DNS detected entry which is the first entry
            ifnull(
                nullif(regexp_extract(_cdn_provider, r'^([^,]*).*'), ''), 'ORIGIN'
            ) as cdn,
            cast(json_extract(payload, '$.timings.ssl') as int64) as tlstime,
            array_length(
                split(json_extract(payload, '$._securityDetails.sanList'), '')
            ) as sanlength,
            -- length(FROM_BASE64(REPLACE(REGEXP_REPLACE(JSON_EXTRACT_SCALAR(payload,
            -- '$._certificates[0]'), ""-----(BEGIN|END) CERTIFICATE-----"", """"),
            -- ""\n"", """"))) AS tlscertsize,
            if(net.host(url) = net.host(page), true, false) as samehost,
            # if toplevel reg_domain will return NULL so we group this as sameDomain
            if(
                net.host(url) = net.host(page) or net.reg_domain(url) = net.reg_domain(
                    page
                ),
                true,
                false
            ) as samedomain
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
        group by client, requestid, page, url, firsthtml, cdn, tlstime, sanlength
    )
where tlstime != -1 and sanlength is not null
group by client, cdn, firsthtml
order by requests desc
