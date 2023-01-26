# standardSQL
# Pages that use media devices (using Blink features)
select distinct client, feature, num_urls, total_urls, pct_urls as pct_urls
from `httparchive.blink_features.usage`
where
    yyyymmdd = '20210701'
    and (
        feature like '%MediaDevices%'
        or feature like '%EnumerateDevices%'
        or feature like '%GetUserMedia%'
        or feature like '%GetDisplayMedia%'
        or feature like '%Camera%'
        or feature like '%Microphone%'
    )
order by
    feature,
    client

    # relevant Blink features:
    # MediaDevicesEnumerateDevices
    # GetUserMediaSecureOrigin
    # GetUserMediaPromise
    # GetUserMediaLegacy
    # GetUserMediaPrefixed
    # GetUserMediaSecureOriginIframe
    # GetUserMediaInsecureOrigin
    # GetUserMediaInsecureOriginIframe
    # V8MediaSession_SetMicrophoneActive_Method
    # V8MediaSession_SetCameraActive_Method
    # GetDisplayMedia
    
