# standardSQL
# PWA features tracked in blink_features.usage
select client, feature, num_urls, total_urls
from `httparchive.blink_features.usage`
where
    yyyymmdd = '20200801' and (
        feature like '%ServiceWorker%'
        or feature like '%BackgroundSync%'
        or feature like '%GetInstalledRelatedApps%'
    )
order by client, num_urls, feature
