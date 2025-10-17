# standardSQL
# Counts of US Privacy String values for websites using IAB US Privacy Framework
# cf.
# https://github.com/InteractiveAdvertisingBureau/USPrivacy/blob/master/CCPA/US%20Privacy%20String.md
with
    totals as (
        select _table_suffix, count(0) as total_websites
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    _table_suffix as client,
    json_query(
        json_value(payload, '$._privacy'), '$.iab_usp.privacy_string.uspString'
    ) as uspstring,
    count(0) as nb_websites,
    total_websites,
    count(0) / total_websites as pct_websites
from `httparchive.pages.2021_07_01_*`
join totals using (_table_suffix)
where
    json_query(json_value(payload, '$._privacy'), '$.iab_usp.privacy_string.uspString')
    is not null
group by client, total_websites, uspstring
order by pct_websites desc, client, uspstring
