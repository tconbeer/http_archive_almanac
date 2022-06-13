# standardSQL
# Counts of purpose declarations on websites using IAB Transparency & Consent Framework
# cf.
# https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#tcdata
# https://stackoverflow.com/a/65054751/7391782
# Warning: fails if there are colons in the keys/values, but these are not expected
create temporary function extractkeyvaluepairs(
    input string
) returns array < struct < key string,
value string > > as (
    (
        select
            array(
                select as struct
                    trim(split(kv, ':') [safe_offset(0)]) as key,
                    trim(split(kv, ':') [safe_offset(1)]) as value
                from t.kv
            )
        from unnest( [struct(split(translate(input, '{}"', '')) as kv)]) t
    )
)
;

with
    pages_iab_tcf_v2 as (
        select
            _table_suffix as client,
            json_query(
                json_value(payload, '$._privacy'), '$.iab_tcf_v2.data'
            ) as metrics
        from `httparchive.pages.2021_07_01_*`
        where
            json_query(
                json_value(payload, '$._privacy'), '$.iab_tcf_v2.data'
            ) is not null
    )

select
    client,
    field,
    result.key as key,
    result.value as value,
    count(0) as number_of_websites
from
    (
        select
            client,
            'purpose.consents' as field,
            extractkeyvaluepairs(json_query(metrics, '$.purpose.consents')) as results
        from pages_iab_tcf_v2
        union all
        select
            client,
            'purpose.legitimateInterests' as field,
            extractkeyvaluepairs(
                json_query(metrics, '$.purpose.legitimateInterests')
            ) as results
        from pages_iab_tcf_v2
        union all
        select
            client,
            'vendor.consents' as field,
            extractkeyvaluepairs(json_query(metrics, '$.vendor.consents')) as results
        from pages_iab_tcf_v2
        union all
        select
            client,
            'vendor.legitimateInterests' as field,
            extractkeyvaluepairs(
                json_query(metrics, '$.vendor.legitimateInterests')
            ) as results
        from pages_iab_tcf_v2
        union all
        select
            client,
            'publisher.consents' as field,
            extractkeyvaluepairs(json_query(metrics, '$.publisher.consents')) as results
        from pages_iab_tcf_v2
        union all
        select
            client,
            'publisher.legitimateInterests' as field,
            extractkeyvaluepairs(
                json_query(metrics, '$.publisher.legitimateInterests')
            ) as results
        from pages_iab_tcf_v2
        union all
        select
            client,
            'publisher.customPurpose.consents' as field,
            extractkeyvaluepairs(
                json_query(metrics, '$.publisher.customPurpose.consents')
            ) as results
        from pages_iab_tcf_v2
        union all
        select
            client,
            'publisher.customPurpose.legitimateInterests' as field,
            extractkeyvaluepairs(
                json_query(metrics, '$.publisher.customPurpose.legitimateInterests')
            ) as results
        from pages_iab_tcf_v2
        union all
        select
            client,
            'specialFeatureOptins' as field,
            extractkeyvaluepairs(
                json_query(metrics, '$.specialFeatureOptins')
            ) as results
        from pages_iab_tcf_v2
        union all
        select
            client,
            'outOfBand.allowedVendors' as field,
            extractkeyvaluepairs(
                json_query(metrics, '$.outOfBand.allowedVendors')
            ) as results
        from pages_iab_tcf_v2
        union all
        select
            client,
            'outOfBand.disclosedVendors' as field,
            extractkeyvaluepairs(
                json_query(metrics, '$.outOfBand.disclosedVendors')
            ) as results
        from pages_iab_tcf_v2
    ),
    unnest(results) result
group by client, field, key, value
order by client, number_of_websites desc
