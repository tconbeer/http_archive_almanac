# standardSQL
# Pages that use Feature-Policy (based on Blink features)
select distinct client, feature, num_urls, total_urls, pct_urls as pct_urls
from `httparchive.blink_features.usage`
where yyyymmdd = '20210701' and feature like '%FeaturePolicy%'
# relevant Blink features:
# CameraDisabledByFeaturePolicyEstimate
# FeaturePolicyAllowAttribute
# FeaturePolicyAllowAttributeDeprecatedSyntax
# FeaturePolicyCommaSeparatedDeclarations
# FeaturePolicyHeader
# FeaturePolicyJSAPI
# FeaturePolicyJSAPIAllowedFeaturesDocument
# FeaturePolicyJSAPIAllowedFeaturesIFrame
# FeaturePolicyJSAPIAllowsFeatureDocument
# FeaturePolicyJSAPIAllowsFeatureIFrame
# FeaturePolicyJSAPIAllowsFeatureOriginDocument
# FeaturePolicyJSAPIFeaturesDocument
# FeaturePolicyJSAPIFeaturesIFrame
# FeaturePolicyJSAPIGetAllowlistDocument
# FeaturePolicyJSAPIGetAllowlistIFrame
# FeaturePolicyReport
# FeaturePolicyReportOnlyHeader
# FeaturePolicySemicolonSeparatedDeclarations
# GetUserMediaCameraDisallowedByFeaturePolicyInCrossOriginIframe
# GetUserMediaMicDisallowedByFeaturePolicyInCrossOriginIframe
# MicrophoneDisabledByFeaturePolicyEstimate
order by feature, client
