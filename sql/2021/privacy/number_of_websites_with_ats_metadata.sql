# standardSQL
# Counts of pages with Ads Transparency Spotlight metadata
select
    _table_suffix as client,
    count(0) as number_of_websites,
    countif(
        json_value(
            json_value(payload, '$._privacy'), '$.ads_transparency_spotlight.present'
        ) = 'true'
    ) as number_of_websites_ats,
    countif(
        json_value(
            json_value(payload, '$._privacy'), '$.ads_transparency_spotlight.present'
        ) = 'true'
    ) / count(0) as pct_websites_ats
from `httparchive.pages.2021_07_01_*`
group by client
order by client, number_of_websites
