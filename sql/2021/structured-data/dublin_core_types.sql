# standardSQL
# Count Dublin Core types
CREATE TEMP FUNCTION getDublinCoreTypes(rendered STRING)
RETURNS ARRAY<STRING>
LANGUAGE js AS """
  try {
    rendered = JSON.parse(rendered);
    return rendered.dublin_core.map(dublin_core => dublin_core.name.toLowerCase());
  } catch (e) {
    return [];
  }
""";

with
    rendered_data as (
        select
            _table_suffix as client,
            url,
            getdublincoretypes(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as dublin_core_types
        from `httparchive.pages.2021_07_01_*`
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    dublin_core_type,
    count(dublin_core_type) as count,
    sum(count(dublin_core_type)) over (partition by client) as freq_dublin_core,
    count(dublin_core_type)
    / sum(count(dublin_core_type)) over (partition by client) as pct_dublin_core,
    count(distinct url) as freq_pages,
    total_pages,
    count(distinct url) / total_pages as pct_pages
from rendered_data, unnest(dublin_core_types) as dublin_core_type
join page_totals using (client)
group by client, dublin_core_type, total_pages
order by pct_dublin_core desc, client
