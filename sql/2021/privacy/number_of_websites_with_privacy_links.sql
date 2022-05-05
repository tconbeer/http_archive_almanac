# standardSQL
# Percent of pages with privacy-related links
select
    _table_suffix as client,
    count(0) as total_websites,
    countif(
        array_length(
            json_query_array(
                json_value(payload, '$._privacy'), '$.privacy_wording_links'
            )
        ) > 0
    ) as websites_with_privacy_link,
    countif(
        array_length(
            json_query_array(
                json_value(payload, '$._privacy'), '$.privacy_wording_links'
            )
        ) > 0
    ) / count(0) as pct_websites_with_privacy_link
from `httparchive.pages.2021_07_01_*`
group by client
order by client
