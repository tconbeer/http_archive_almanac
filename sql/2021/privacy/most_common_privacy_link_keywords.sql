# standardSQL
# Pages with certain keywords indicating privacy-related links
with
    privacy_link_keywords as (
        select
            _table_suffix as client,
            array(
                select distinct lower(kw)
                from
                    unnest(
                        json_query_array(
                            json_value(payload, '$._privacy'), '$.privacy_wording_links'
                        )
                    ) as p,
                    unnest(json_value_array(p, '$.keywords')) kw
            ) as keywords_per_site
        from `httparchive.pages.2021_07_01_*`
    ),

    totals as (
        select _table_suffix as client, count(0) as total_websites
        from `httparchive.pages.2021_07_01_*`
        group by client
    )

select
    client,
    keyword,
    count(0) as number_of_websites_with_keyword,
    total_websites,
    count(0) / total_websites as pct_websites_with_keyword
from privacy_link_keywords
join totals using(client), unnest(keywords_per_site) keyword
group by client, keyword, total_websites
order by client, number_of_websites_with_keyword desc, keyword
