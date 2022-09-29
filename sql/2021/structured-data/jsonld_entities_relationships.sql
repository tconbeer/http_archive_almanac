# standardSQL
# Count JSON-LD entities and relationships
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
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    jsonld_entity_relationship._from,
    jsonld_entity_relationship.relationship,
    jsonld_entity_relationship._to,
    jsonld_entity_relationship.depth,
    count(0) as freq_relationship,
    sum(count(0)) over (partition by client) as total_relationship,
    count(0) / sum(count(0)) over (partition by client) as pct_relationship,
    count(distinct url) as freq_pages,
    total_pages,
    count(distinct url) / total_pages as pct_pages
from rendered_data, unnest(jsonld_entities_relationships) as jsonld_entity_relationship
join page_totals using (client)
group by
    client,
    jsonld_entity_relationship._from,
    jsonld_entity_relationship.relationship,
    jsonld_entity_relationship._to,
    jsonld_entity_relationship.depth,
    total_pages
order by pct_relationship desc, client
limit 1000
