# standardSQL
# Count JSON-LD contexts
create temp function getjsonldcontexts(rendered string)
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
      return getDeep('@context', jsonld_script);
    }).flat().filter(context => typeof context === 'string');
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
            getjsonldcontexts(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as jsonld_context
        from `httparchive.pages.2021_07_01_*`
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    net.reg_domain(jsonld_context) as jsonld_context,
    count(0) as freq_jsonld_context,
    sum(count(0)) over (partition by client) as total_jsonld_context,
    count(0) / sum(count(0)) over (partition by client) as pct_jsonld_context,
    count(distinct url) as freq_pages,
    total_pages,
    count(distinct url) / total_pages as pct_pages
from rendered_data, unnest(jsonld_context) as jsonld_context
join page_totals using(client)
group by client, jsonld_context, total_pages
order by pct_jsonld_context desc, client
