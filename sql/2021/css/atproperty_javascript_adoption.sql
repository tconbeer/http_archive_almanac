# standardSQL
# CSS.registerProperty adoption
# https://developer.mozilla.org/en-US/docs/Web/API/CSS/RegisterProperty
select distinct client, num_urls, total_urls, pct_urls
from `httparchive.blink_features.usage`
where yyyymmdd = '20210701' and feature = 'CSSRegisterProperty'
