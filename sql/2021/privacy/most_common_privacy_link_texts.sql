# standardSQL
# Percent of certain texts containing keywords indicating privacy-related links
with
    privacy_link_texts as (
        select
            _table_suffix as client,
            array(
                select distinct lower(json_value(p, '$.text'))
                from
                    unnest(
                        json_query_array(
                            json_value(payload, '$._privacy'), '$.privacy_wording_links'
                        )
                    ) as p
            ) as texts_per_site
        from `httparchive.pages.2021_07_01_*`
    ),

    totals as (
        select _table_suffix as client, count(0) as total_websites
        from `httparchive.pages.2021_07_01_*`
        group by client
    )

select
    client,
    text,
    count(0) as number_of_websites_with_text,
    total_websites,
    count(0) / total_websites as pct_websites_with_text
from privacy_link_texts
join totals using (client), unnest(texts_per_site) text
group by client, text, total_websites
order by client, number_of_websites_with_text desc, text
