# standardSQL
# Counts of CMPs using IAB Transparency & Consent Framework
# cf.
# https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#tcdata
with
    totals as (
        select _table_suffix, count(0) as total_websites
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    _table_suffix as client,
    json_value(json_value(payload, '$._privacy'), '$.iab_tcf_v2.data.cmpId') as cmpid,
    count(0) as number_of_websites,
    total_websites,
    count(0) / total_websites as pct_websites
from `httparchive.pages.2021_07_01_*`
join totals using(_table_suffix)
where
    json_value(json_value(payload, '$._privacy'), '$.iab_tcf_v2.data.cmpId') is not null
group by client, total_websites, cmpid
order by pct_websites desc, client, cmpid
