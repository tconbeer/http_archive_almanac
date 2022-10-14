# standardSQL
# Count Classic Microformats types
CREATE TEMP FUNCTION getClassicMicroformatsTypes(rendered STRING)
RETURNS ARRAY<STRUCT<name STRING, count NUMERIC>>
LANGUAGE js AS """
  try {
    rendered = JSON.parse(rendered);
    return rendered.microformats_classic_types.map(microformats_classic_type => ({name: microformats_classic_type.name, count: microformats_classic_type.count}));
  } catch (e) {
    return [];
  }
""";

with
    rendered_data as (
        select
            _table_suffix as client,
            url,
            getclassicmicroformatstypes(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as classic_microformats_types
        from `httparchive.pages.2021_07_01_*`
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    classic_microformats_type.name as classic_microformats_type,
    sum(classic_microformats_type.count) as freq_microformat,
    sum(sum(classic_microformats_type.count)) over (
        partition by client
    ) as total_microformat,
    sum(
        classic_microformats_type.count
    ) / sum(sum(classic_microformats_type.count)) over (
        partition by client
    ) as pct_microformat,
    count(distinct url) as freq_pages,
    total_pages,
    count(distinct url) / total_pages as pct_pages
from rendered_data, unnest(classic_microformats_types) as classic_microformats_type
join page_totals using (client)
group by client, classic_microformats_type, total_pages
order by freq_microformat desc, client
