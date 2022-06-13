# standardSQL
# Count JSON-LD sameAs values
create temp function getjsonldsameases(rendered string)
returns array
< string
>
language js
as """
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
      return getDeep('sameAs', jsonld_script);
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
            getjsonldsameases(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as jsonld_sameases
        from `httparchive.pages.2021_07_01_*`
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    net.reg_domain(jsonld_sameas) as jsonld_sameas,
    count(0) as freq_jsonld_sameas,
    sum(count(0)) over (partition by client) as total_jsonld_sameas,
    count(0) / sum(count(0)) over (partition by client) as pct_jsonld_sameas,
    count(distinct url) as freq_pages,
    total_pages,
    count(distinct url) / total_pages as pct_pages
from rendered_data, unnest(jsonld_sameases) as jsonld_sameas
join page_totals using(client)
group by client, jsonld_sameas, total_pages
order by pct_jsonld_sameas desc, client
limit 1000
