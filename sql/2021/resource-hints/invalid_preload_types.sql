# standardSQL
# returns the number of valid and invalid preload resource types
create temporary function getinvalidtypes(almanac_string string)
returns
    array<
        struct<
            type string,
            num_occurrences numeric >> language js
            as
                '''
try {
  // obtained from https://developer.mozilla.org/en-US/docs/Web/HTML/Link_types/preload#what_types_of_content_can_be_preloaded
  var validResourceTypes = [
    "audio",
    "document",
    "embed",
    "fetch",
    "font",
    "image",
    "object",
    "script",
    "style",
    "track",
    "worker",
    "video",
  ];

  var almanac = JSON.parse(almanac_string);
  if (almanac === null || Array.isArray(almanac) || typeof almanac !== "object")
    return [];

  var nodes = almanac["link-nodes"] ? almanac["link-nodes"]["nodes"] : [];
  nodes = typeof nodes == "string" ? JSON.parse(nodes) : nodes;

  var validTypesCnt = 0;
  var invalidTypesCnt = 0;
  var invalidTypes = {};

  for (var node of nodes) {
    if (node["rel"] && node["rel"].toLowerCase() === "preload") {
      if (!node["as"]) {
        invalidTypes["missing_as"] = ++invalidTypes["missing_as"] || 1;
        invalidTypesCnt += 1;
      } else if (validResourceTypes.indexOf(node["as"].toLowerCase()) >= 0) {
        validTypesCnt += 1;
      } else {
        invalidTypes[node["as"].toLowerCase()] =
          ++invalidTypes[node["as"].toLowerCase()] || 1;
        invalidTypesCnt += 1;
      }
    }
  }

  var result = [
    { type: "valid", num_occurrences: validTypesCnt },
    { type: "invalid", num_occurrences: invalidTypesCnt },
  ];

  for (var type in invalidTypes) {
    result.push({
      type,
      num_occurrences: invalidTypes[type],
    });
  }
  return result;
} catch (error) {
  return [];
}
'''
;

select
    client,
    type,
    sum(num_occurrences) as total_occurrences,
    sum(sum(num_occurrences)) over (partition by client) as total,
    sum(num_occurrences) / sum(sum(num_occurrences)) over (partition by client) as pct
from
    (
        select _table_suffix as client, invalid_type.type, invalid_type.num_occurrences
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(
                getinvalidtypes(json_extract_scalar(payload, '$._almanac'))
            ) as invalid_type
        where payload is not null
    )
group by client, type
order by total_occurrences desc
