# standardSQL
# Count JSON-LD types
CREATE TEMP FUNCTION getJSONLDTypes(rendered STRING)
RETURNS ARRAY<STRING>
LANGUAGE js AS """
  try {
    const arrayify = (value) => Array.isArray(value) ? value : [value];

    const getDeep = (key, o) => {
      if (Array.isArray(o)) return o.map(child => getDeep(key, child)).flat();

      if (o instanceof Object) {
        return Object.entries(o).map(([k, value]) => {
          if (k === key) return [...arrayify(value), ...getDeep(value)];
          return getDeep(value);
        }).flat();
      }

      return [];
    }

    rendered = JSON.parse(rendered);
    const jsonld_scripts = rendered.jsonld_scripts;
    return jsonld_scripts.map(jsonld_script => {
      jsonld_script = JSON.parse(jsonld_script);
      return getDeep('@type', jsonld_script);
    }).flat();
  } catch (e) {
    return [];
  }
""";

with
    rendered_data as (
        select
            _table_suffix as client,
            url,
            getjsonldtypes(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as jsonld_types
        from `httparchive.pages.2021_07_01_*`
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    jsonld_type,
    count(jsonld_type) as freq_jsonld_type,
    sum(count(jsonld_type)) over (partition by client) as total_jsonld_type,
    count(jsonld_type)
    / sum(count(jsonld_type)) over (partition by client) as pct_jsonld_type,
    count(distinct url) as freq_pages,
    total_pages,
    count(distinct url) / total_pages as pct_pages
from rendered_data, unnest(jsonld_types) as jsonld_type
join page_totals using (client)
group by client, jsonld_type, total_pages
order by pct_jsonld_type desc, client
