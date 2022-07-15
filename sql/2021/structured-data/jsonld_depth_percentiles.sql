# standardSQL
# Find the most nested entity in a JSON-LD document
create temp function getjsonldentitiesrelationships(rendered string)
returns array < struct < _from string,
relationship string,
_to string,
depth numeric
>> language js
as """
  try {
    const types = new Map();

    const loadTypes = (o) => {
      if (Array.isArray(o)) {
        o.forEach(loadTypes);
      } else if (o instanceof Object) {
        if (o['@id'] && o['@type']) {
          types.set(o['@id'], o['@type']);
        }

        Object.values(o).forEach(loadTypes);
      }
    }

    const arrayify = (value) => Array.isArray(value) ? value : [value];

    const getEntitiesAndRelationships = (o, _from, relationship, depth = 0) => {
      if (Array.isArray(o)) return o.map(value => getEntitiesAndRelationships(value, _from, relationship, depth)).flat();

      if (o instanceof Object) {
        const type = types.get(o['@id']) || o['@type'];
        return [{_from, relationship, _to: type, depth}, ...Object.entries(o).map(([k, value]) => getEntitiesAndRelationships(value, type, k, depth + 1))].flat();
      }

      return [];
    }

    rendered = JSON.parse(rendered);
    const jsonld_scripts = rendered.jsonld_scripts.map(JSON.parse);
    loadTypes(jsonld_scripts);

    return jsonld_scripts.map(jsonld_script => getEntitiesAndRelationships(jsonld_script, undefined, undefined, 0)).flat();
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
            getjsonldentitiesrelationships(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as jsonld_entities_relationships
        from `httparchive.pages.2021_07_01_*`
    )

select
    client,
    percentile,
    approx_quantiles(
        jsonld_entity_relationship.depth, 1000) [offset (percentile * 10)
    ] as depth,
    array_to_string(array_agg(distinct url limit 5), ' ') as sample_urls
from
    rendered_data,
    unnest(jsonld_entities_relationships) as jsonld_entity_relationship,
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by client, percentile
order by client, percentile
