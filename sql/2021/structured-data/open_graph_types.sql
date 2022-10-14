# standardSQL
# Count Open Graph types
CREATE TEMP FUNCTION getOpenGraphTypes(rendered STRING)
RETURNS ARRAY<STRING>
LANGUAGE js AS """
  try {
    rendered = JSON.parse(rendered);
    return rendered.opengraph.map(opengraph => opengraph.property.toLowerCase());
  } catch (e) {
    return [];
  }
""";

with
    rendered_data as (
        select
            _table_suffix as client,
            url,
            getopengraphtypes(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as open_graph_types
        from `httparchive.pages.2021_07_01_*`
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    open_graph_type,
    count(open_graph_type) as freq_open_graph_type,
    sum(count(open_graph_type)) over (partition by client) as total_open_graph_types,
    count(open_graph_type)
    / sum(count(open_graph_type)) over (partition by client) as pct_open_graph_types,
    count(distinct url) as freq_pages,
    total_pages,
    count(distinct url) / total_pages as pct_pages
from rendered_data, unnest(open_graph_types) as open_graph_type
join page_totals using (client)
group by client, open_graph_type, total_pages
order by pct_open_graph_types desc, client
