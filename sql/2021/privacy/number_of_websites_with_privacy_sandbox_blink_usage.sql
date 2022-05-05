# standardSQL
# Pages that use Privacy Sandbox-related features (based on Blink features)
select distinct client, feature, num_urls, total_urls, pct_urls as pct_urls
from `httparchive.blink_features.usage`
where
    yyyymmdd = '20210701' and (
        feature = 'InterestCohortAPI_interestCohort_Method'
        or feature = 'V8Navigator_JoinAdInterestGroup_Method'
        or feature = 'V8Navigator_LeaveAdInterestGroup_Method'
        or feature = 'V8Navigator_UpdateAdInterestGroups_Method'
        or feature = 'V8Navigator_RunAdAuction_Method'
        or feature = 'ConversionRegistration'
        or feature = 'ImpressionRegistration'
        or feature = 'ConversionAPIAll'
        or feature = 'SamePartyCookieAttribute'
        or feature = 'V8Document_HasTrustToken_Method'
        or feature = 'HTMLFencedFrameElement'
    )
order by feature, client
