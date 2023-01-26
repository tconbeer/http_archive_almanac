# standardSQL
# Pages that request DNT status (based on Blink features)
select distinct client, feature, num_urls, total_urls, pct_urls
from `httparchive.blink_features.usage`
where yyyymmdd = '20210701' and feature = 'NavigatorDoNotTrack'
order by
    feature,
    client

    # relevant Blink features:
    # DNT: NavigatorDoNotTrack
    
