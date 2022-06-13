# standardSQL
# Popular mobile input types
create temporary function getinputtypes(payload string)
returns array
< string
> language js
as '''
try {
  const almanac = JSON.parse(payload);
  return almanac.input_elements.nodes.map(function(node) {
    if (!node.type) {
      return "n/a";
    }

    return node.type.toLowerCase();
  });
} catch (e) {
  return [];
}
'''
;

select
    total_pages_with_inputs,
    total_inputs,

    input_type,
    count(input_type) as occurences,
    count(distinct url) as total_pages_used_in,

    count(input_type) / total_inputs as pct_of_all_inputs,
    count(distinct url) / total_pages_with_inputs as pct_used_in_pages
from
    `httparchive.pages.2021_07_01_mobile`,
    (
        select count(0) as total_pages_with_inputs
        from `httparchive.pages.2021_07_01_mobile`
        where
            safe_cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'), '$.input_elements.total'
                ) as int64
            ) > 0
    ),
    (
        select
            sum(
                safe_cast(
                    json_extract_scalar(
                        json_extract_scalar(payload, '$._almanac'),
                        '$.input_elements.total'
                    ) as int64
                )
            ) as total_inputs
        from `httparchive.pages.2021_07_01_mobile`
    ),
    unnest(getinputtypes(json_extract_scalar(payload, '$._almanac'))) as input_type
group by input_type, total_inputs, total_pages_with_inputs
order by occurences desc
