# standardSQL
# Pages that use a device sensor (based on Blink features)
select distinct client, feature, num_urls, total_urls, pct_urls
from `httparchive.blink_features.usage`
where
    yyyymmdd = '20210701' and (
        feature like '%DeviceMotion%'
        or feature like '%DeviceOrientation%'
        or feature like '%DeviceProximity%'
        or feature like '%DeviceLight%'
    )
order by feature, client
