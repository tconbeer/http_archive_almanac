# standardSQL
# Count JSON-LD relationships
create temp function getjsonldrelationships(rendered string)
returns array
< string
> language js as """
  try {
    const arrayify = (value) => Array.isArray(value) ? value : [value];

    const getRelationships = (o) => {
      if (Array.isArray(o)) return o.map(child => getRelationships(child)).flat();

      if (o instanceof Object) {
        return Object.entries(o).map(([k, value]) => {
          if (!k.startsWith('@')) return [k, ...getRelationships(value)];
          return getRelationships(value);
        }).flat();
      }

      return [];
    }

    rendered = JSON.parse(rendered);
    const jsonld_scripts = rendered.jsonld_scripts;
    return jsonld_scripts.map(jsonld_script => {
      jsonld_script = JSON.parse(jsonld_script);
      return getRelationships(jsonld_script);
    }).flat();
  } catch (e) {
    return [];
  }
"""
;

with
    rendered_data as (
        select
            _table_suffix as client,
            url,
            getjsonldrelationships(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as jsonld_relationships
        from `httparchive.pages.2021_07_01_*`
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    jsonld_relationship,
    count(jsonld_relationship) as freq_relationship,
    sum(count(jsonld_relationship)) over (partition by client) as total_relationship,
    count(jsonld_relationship)
    / sum(count(jsonld_relationship)) over (partition by client) as pct_relationship,
    count(distinct url) as freq_pages,
    total_pages,
    count(distinct url) / total_pages as pct_pages
from rendered_data, unnest(jsonld_relationships) as jsonld_relationship
join page_totals using (client)
group by client, jsonld_relationship, total_pages
order by pct_relationship desc, client
limit 1000
