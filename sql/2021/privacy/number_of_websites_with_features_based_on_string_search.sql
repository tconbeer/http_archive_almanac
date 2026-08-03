# standardSQL
# Counts of websites using a certain privacy-related feature,
# based on searching Document and Script bodies
# (all those loaded on a page, regardless of the origin)
with
    privacy_custom_metrics_data as (
        select _table_suffix as client, json_value(payload, '$._privacy') as metrics
        from `httparchive.pages.2021_07_01_*`
        where json_value(payload, '$._privacy') is not null
    )

select
    *,
    number_of_websites_document_interestcohort
    / number_of_websites as pct_websites_document_interestcohort,
    number_of_websites_navigator_donottrack
    / number_of_websites as pct_websites_navigator_donottrack,
    number_of_websites_navigator_globalprivacycontrol
    / number_of_websites as pct_websites_navigator_globalprivacycontrol,
    number_of_websites_document_permissionspolicy
    / number_of_websites as pct_websites_document_permissionspolicy,
    number_of_websites_document_featurepolicy
    / number_of_websites as pct_websites_document_featurepolicy,
    number_of_websites_navigator_mediadevices_enumeratedevices
    / number_of_websites as pct_websites_navigator_mediadevices_enumeratedevices,
    number_of_websites_navigator_mediadevices_getusermedia
    / number_of_websites as pct_websites_navigator_mediadevices_getusermedia,
    number_of_websites_navigator_mediadevices_getdisplaymedia
    / number_of_websites as pct_websites_navigator_mediadevices_getdisplaymedia,
    number_of_websites_navigator_mediadevices_any
    / number_of_websites as pct_websites_navigator_mediadevices_any,
    number_of_websites_navigator_geolocation_getcurrentposition
    / number_of_websites as pct_websites_navigator_geolocation_getcurrentposition,
    number_of_websites_navigator_geolocation_watchposition
    / number_of_websites as pct_websites_navigator_geolocation_watchposition,
    number_of_websites_navigator_geolocation_any
    / number_of_websites as pct_websites_navigator_geolocation_any
from
    (
        select
            client,
            count(0) as number_of_websites,
            countif(
                json_value(metrics, '$.document_interestCohort') = 'true'
            ) as number_of_websites_document_interestcohort,
            countif(
                json_value(metrics, '$.navigator_doNotTrack') = 'true'
            ) as number_of_websites_navigator_donottrack,
            countif(
                json_value(metrics, '$.navigator_globalPrivacyControl') = 'true'
            ) as number_of_websites_navigator_globalprivacycontrol,
            countif(
                json_value(metrics, '$.document_permissionsPolicy') = 'true'
            ) as number_of_websites_document_permissionspolicy,
            countif(
                json_value(metrics, '$.document_featurePolicy') = 'true'
            ) as number_of_websites_document_featurepolicy,

            countif(
                json_value(
                    metrics, '$.media_devices.navigator_mediaDevices_enumerateDevices'
                )
                = 'true'
            ) as number_of_websites_navigator_mediadevices_enumeratedevices,
            countif(
                json_value(
                    metrics, '$.media_devices.navigator_mediaDevices_getUserMedia'
                )
                = 'true'
            ) as number_of_websites_navigator_mediadevices_getusermedia,
            countif(
                json_value(
                    metrics, '$.media_devices.navigator_mediaDevices_getDisplayMedia'
                )
                = 'true'
            ) as number_of_websites_navigator_mediadevices_getdisplaymedia,

            countif(
                json_value(
                    metrics, '$.media_devices.navigator_mediaDevices_enumerateDevices'
                )
                = 'true'
                or json_value(
                    metrics, '$.media_devices.navigator_mediaDevices_getUserMedia'
                )
                = 'true'
                or json_value(
                    metrics, '$.media_devices.navigator_mediaDevices_getDisplayMedia'
                )
                = 'true'
            ) as number_of_websites_navigator_mediadevices_any,

            countif(
                json_value(
                    metrics, '$.geolocation.navigator_geolocation_getCurrentPosition'
                )
                = 'true'
            ) as number_of_websites_navigator_geolocation_getcurrentposition,
            countif(
                json_value(metrics, '$.geolocation.navigator_geolocation_watchPosition')
                = 'true'
            ) as number_of_websites_navigator_geolocation_watchposition,

            countif(
                json_value(
                    metrics, '$.geolocation.navigator_geolocation_getCurrentPosition'
                )
                = 'true'
                or json_value(
                    metrics, '$.geolocation.navigator_geolocation_watchPosition'
                )
                = 'true'
            ) as number_of_websites_navigator_geolocation_any

        from privacy_custom_metrics_data
        group by client
    )
order by client
