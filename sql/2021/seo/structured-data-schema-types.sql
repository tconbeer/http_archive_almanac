# standardSQL
# Structured data schema types
# returns all the data we need from _wpt_bodies
CREATE TEMPORARY FUNCTION getStructuredSchemaWptBodies(wpt_bodies_string STRING)
RETURNS STRUCT<
  jsonld_and_microdata_types ARRAY<STRING>
> LANGUAGE js AS '''
var result = {};


try {
    var wpt_bodies = JSON.parse(wpt_bodies_string);

    if (Array.isArray(wpt_bodies) || typeof wpt_bodies != 'object') return result;

    if (wpt_bodies.structured_data && wpt_bodies.structured_data.rendered) {
        var temp = wpt_bodies.structured_data.rendered.jsonld_and_microdata_types;
        result.jsonld_and_microdata_types = temp.map(a => a.name);
    }

} catch (e) {}
return result;
''';

select client, type, total, count(0) as count, safe_divide(count(0), total) as pct
from
    (
        select
            _table_suffix as client,
            total,
            getstructuredschemawptbodies(
                json_extract_scalar(payload, '$._wpt_bodies')
            ) as structured_schema_wpt_bodies_info
        from `httparchive.pages.2021_07_01_*`
        join
            (
                select _table_suffix, count(0) as total
                from `httparchive.pages.2021_07_01_*`
                group by _table_suffix
            ) using (_table_suffix)
    ),
    unnest(structured_schema_wpt_bodies_info.jsonld_and_microdata_types) as type
group by total, type, client
having count > 50
order by count desc
