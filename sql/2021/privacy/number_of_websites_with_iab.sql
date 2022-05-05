# standardSQL
# Counts of pages with IAB Frameworks (Transparency & Consent / US Privacy)
with
    privacy_custom_metrics_data as (
        select _table_suffix as client, json_value(payload, '$._privacy') as metrics
        from `httparchive.pages.2021_07_01_*`
        where json_value(payload, '$._privacy') is not null
    )

select
    *,
    number_of_websites_with_iab_tcf_v1
    / number_of_websites
    as pct_websites_with_iab_tcf_v1,
    number_of_websites_with_iab_tcf_v2
    / number_of_websites
    as pct_websites_with_iab_tcf_v2,
    number_of_websites_with_iab_tcf_v1_compliant
    / number_of_websites_with_iab_tcf_v1
    as pct_websites_with_iab_tcf_v1_compliant,
    number_of_websites_with_iab_tcf_v2_compliant
    / number_of_websites_with_iab_tcf_v2
    as pct_websites_with_iab_tcf_v2_compliant,
    number_of_websites_with_iab_tcf_any
    / number_of_websites
    as pct_websites_with_iab_tcf_any,
    number_of_websites_with_iab_usp / number_of_websites as pct_websites_with_iab_usp,
    number_of_websites_with_iab_any / number_of_websites as pct_websites_with_iab_any
from
    (
        select
            client,
            count(0) as number_of_websites,
            countif(
                json_value(metrics, '$.iab_tcf_v1.present') = 'true'
            ) as number_of_websites_with_iab_tcf_v1,
            countif(
                json_value(metrics, '$.iab_tcf_v2.present') = 'true'
            ) as number_of_websites_with_iab_tcf_v2,
            countif(
                json_value(metrics, '$.iab_tcf_v1.present') = 'true' or json_value(
                    metrics, '$.iab_tcf_v2.present'
                ) = 'true'
            ) as number_of_websites_with_iab_tcf_any,
            countif(
                json_value(metrics, '$.iab_usp.present') = 'true'
            ) as number_of_websites_with_iab_usp,
            countif(
                json_value(metrics, '$.iab_tcf_v1.present') = 'true' or json_value(
                    metrics, '$.iab_tcf_v2.present'
                ) = 'true' or json_value(metrics, '$.iab_usp.present') = 'true'
            ) as number_of_websites_with_iab_any,
            countif(
                json_value(metrics, '$.iab_tcf_v1.present') = 'true' and json_value(
                    metrics, '$.iab_tcf_v1.compliant_setup'
                ) = 'true'
            ) as number_of_websites_with_iab_tcf_v1_compliant,
            countif(
                json_value(metrics, '$.iab_tcf_v2.present') = 'true' and json_value(
                    metrics, '$.iab_tcf_v2.compliant_setup'
                ) = 'true'
            ) as number_of_websites_with_iab_tcf_v2_compliant
        from privacy_custom_metrics_data
        group by client
    )
order by client
