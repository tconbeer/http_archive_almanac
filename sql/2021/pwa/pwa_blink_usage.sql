# standardSQL
# PWA features tracked in blink_features.usage
select distinct client, feature, num_urls, total_urls, num_urls / total_urls as pct
from `httparchive.blink_features.usage`
where
    yyyymmdd = '20210701'
    and (
        feature like '%ServiceWorker%'
        or feature like '%BackgroundSync%'
        or feature like '%GetInstalledRelatedApps%'
    )
order by num_urls desc, client, feature
