# standardSQL
# 01_18-23: % of pages using JS APIs
select
    client,
    count(0) as total,
    countif(atomics > 0) as atomics,
    round(countif(atomics > 0) * 100 / count(0), 2) as pct_atomics,
    countif(intl > 0) as intl,
    round(countif(intl > 0) * 100 / count(0), 2) as pct_intl,
    countif(proxy > 0) as proxy,
    round(countif(proxy > 0) * 100 / count(0), 2) as pct_proxy,
    countif(sharedarraybuffer > 0) as sharedarraybuffer,
    round(countif(sharedarraybuffer > 0) * 100 / count(0), 2) as pct_sharedarraybuffer,
    countif(weakmap > 0) as weakmap,
    round(countif(weakmap > 0) * 100 / count(0), 2) as pct_weakmap,
    countif(weakset > 0) as weakset,
    round(countif(weakset > 0) * 100 / count(0), 2) as pct_weakset
from
    (
        select
            client,
            countif(body like '%Atomics.%') as atomics,
            countif(body like '%new Intl.%') as intl,
            countif(body like '%new Proxy%') as proxy,
            countif(body like '%new SharedArrayBuffer(%') as sharedarraybuffer,
            countif(body like '%new WeakMap%') as weakmap,
            countif(body like '%new WeakSet%') as weakset
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and type = 'script'
        group by client, page
    )
group by client
order by client
