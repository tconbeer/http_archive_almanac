# standardSQL
# Count Twitter types
CREATE TEMP FUNCTION getTwitterTypes(rendered STRING)
RETURNS ARRAY<STRING>
LANGUAGE js AS """
  try {
    rendered = JSON.parse(rendered);
    return rendered.twitter.map(twitter => twitter.name.toLowerCase());
  } catch (e) {
    return [];
  }
""";

with
    rendered_data as (
        select
            _table_suffix as client,
            url,
            gettwittertypes(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as twitter_types
        from `httparchive.pages.2021_07_01_*`
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    twitter_type,
    count(twitter_type) as freq_twitter,
    sum(count(twitter_type)) over (partition by client) as total_twitter,
    count(twitter_type)
    / sum(count(twitter_type)) over (partition by client) as pct_twitter,
    count(distinct url) as freq_pages,
    total_pages,
    count(distinct url) / total_pages as pct_pages
from rendered_data, unnest(twitter_types) as twitter_type
join page_totals using (client)
group by client, twitter_type, total_pages
order by pct_twitter desc, client
