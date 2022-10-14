# standardSQL
# Count Facebook types
CREATE TEMP FUNCTION getFacebookTypes(rendered STRING)
RETURNS ARRAY<STRING>
LANGUAGE js AS """
  try {
    rendered = JSON.parse(rendered);
    return rendered.facebook.map(facebook => facebook.property.toLowerCase());
  } catch (e) {
    return [];
  }
""";

with
    rendered_data as (
        select
            _table_suffix as client,
            url,
            getfacebooktypes(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as facebook_type
        from `httparchive.pages.2021_07_01_*`
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    facebook_type,
    count(facebook_type) as freq_facebook,
    sum(count(facebook_type)) over (partition by client) as total_facebook,
    count(facebook_type)
    / sum(count(facebook_type)) over (partition by client) as pct_facebook,
    count(distinct url) as freq_pages,
    total_pages,
    count(distinct url) / total_pages as pct_pages
from rendered_data, unnest(facebook_type) as facebook_type
join page_totals using (client)
group by client, facebook_type, total_pages
order by freq_facebook desc, client
