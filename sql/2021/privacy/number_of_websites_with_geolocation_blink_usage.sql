# standardSQL
# Pages that use geolocation features (based on Blink features)
select distinct client, feature, num_urls, total_urls, pct_urls as pct_urls
from `httparchive.blink_features.usage`
where yyyymmdd = '20210701' and feature like '%Geolocation%'
# relevant Blink features:
# GeolocationGetCurrentPosition
# GeolocationWatchPosition
# GeolocationDisabledByFeaturePolicy
# GeolocationDisallowedByFeaturePolicyInCrossOriginIframe
# GeolocationInsecureOriginIframe
# GeolocationInsecureOrigin
# GeolocationSecureOrigin
# GeolocationSecureOriginIframe
# GeolocationInsecureOriginDeprecatedNotRemoved
# GeolocationInsecureOriginIframeDeprecatedNotRemoved
order by feature, client
