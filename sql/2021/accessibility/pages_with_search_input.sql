# standardSQL
# Pages with search input
CREATE TEMPORARY FUNCTION hasSearchInput(payload STRING)
RETURNS BOOLEAN LANGUAGE js AS '''
  try {
    const almanac = JSON.parse(payload);
    return almanac.input_elements.nodes.some((node) => {
      if (node.type.toLowerCase() === "search") {
        return true;
      }

      // Detect regular inputs of type text and the first word being "search"
      if (node.type.toLowerCase() === "text" &&
          /^\\s*search(\\s|$)/i.test(node.placeholder || '')) {
        return true;
      }

      return false;
    });

  } catch (e) {
    return false;
  }
''';

select
    client,
    count(0) as total_sites,
    countif(has_inputs) as total_with_inputs,
    countif(has_search_input) as total_with_search_input,

    # Perc of all sites which have a search input
    countif(has_search_input) / count(0) as perc_sites_with_search_input,
    # Of sites that have at least 1 input element, how many have a search input
    countif(has_search_input)
    / countif(has_inputs) as perc_input_sites_with_search_input
from
    (
        select
            _table_suffix as client,
            safe_cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'), '$.input_elements.total'
                ) as int64
            )
            > 0 as has_inputs,
            hassearchinput(
                json_extract_scalar(payload, '$._almanac')
            ) as has_search_input
        from `httparchive.pages.2021_07_01_*`
    )
group by client
