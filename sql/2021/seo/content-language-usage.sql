# standardSQL
# Content language usage
# returns all the data we need from _almanac
create temporary function getcontentlanguagesalmanac(almanac_string string)
returns array
< string
> language js
as '''
var result = [];
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return ["NO PAYLOAD"];

    if (almanac && almanac["meta-nodes"] && almanac["meta-nodes"].nodes && almanac["meta-nodes"].nodes.filter) {
      result = almanac["meta-nodes"].nodes.filter(n => n["http-equiv"] && n["http-equiv"].toLowerCase().trim() == 'content-language' && n.content).map(am => am.content.toLowerCase().trim());
    }

    if (result.length === 0)
        result.push("NO TAG");

} catch (e) {result.push("ERROR "+e);} // results show some issues with the validity of the payload
return result;
'''
;

select
    client,
    total,

    content_language,
    count(0) as count,
    safe_divide(count(0), total) as pct
from
    (
        select
            _table_suffix as client,
            total,
            getcontentlanguagesalmanac(
                json_extract_scalar(payload, '$._almanac')
            ) as content_languages
        from `httparchive.pages.2021_07_01_*`
        join
            (

                select _table_suffix, count(0) as total
                from `httparchive.pages.2021_07_01_*`

                group by _table_suffix
            )
            using(_table_suffix)
    ),
    unnest(content_languages) as content_language
group by total, content_language, client
order by count desc, content_language, client desc
limit 1000
