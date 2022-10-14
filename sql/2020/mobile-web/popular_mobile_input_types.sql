# standardSQL
# Popular mobile input types
CREATE TEMPORARY FUNCTION getInputTypes(payload STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
  try {
    const almanac = JSON.parse(payload);
    return almanac.input_elements.nodes.map(function(node) {
      return node.type.toLowerCase();
    });
  } catch (e) {
    return [];
  }
''';

select
    total_pages_with_inputs,
    sum(count(0)) over () as total_inputs,

    input_type,
    count(input_type) as occurences,
    count(distinct url) as total_pages_used_in,

    count(input_type) / sum(count(0)) over () as perc_of_all_inputs,
    count(distinct url) / total_pages_with_inputs as perc_used_in_pages
from
    `httparchive.pages.2020_08_01_mobile`,
    (
        select count(0) as total_pages_with_inputs
        from `httparchive.pages.2020_08_01_mobile`
        where
            safe_cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'), '$.input_elements.total'
                ) as int64
            )
            > 0
    ),
    unnest(getinputtypes(json_extract_scalar(payload, '$._almanac'))) as input_type
group by input_type, total_pages_with_inputs
order by occurences desc
