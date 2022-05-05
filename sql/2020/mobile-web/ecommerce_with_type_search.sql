# standardSQL
# Ecommerce sites using type=search inputs
create temporary function getsearchinputstats(payload string)
returns struct < has_inputs boolean,
has_search_inputs boolean
> language js
as '''
  try {
    const almanac = JSON.parse(payload);
    const search_node_index = almanac.input_elements.nodes.findIndex((node) => {
      return node.type.toLowerCase() === 'search';
    });

    return {
      has_inputs: almanac.input_elements.total > 0,
      has_search_inputs: search_node_index >= 0,
    };
  } catch (e) {
    return {
      has_inputs: false,
      has_search_inputs: false,
    };
  }
'''
;

select
    client,
    countif(search_input_stats.has_inputs) as sites_with_inputs,

    countif(search_input_stats.has_search_inputs) as sites_with_search_inputs,
    countif(search_input_stats.has_search_inputs) / countif(
        search_input_stats.has_inputs
    ) as perc_sites_with_search_inputs
from
    (
        select
            _table_suffix as client,
            getsearchinputstats(
                json_extract_scalar(payload, '$._almanac')
            ) as search_input_stats,
            url
        from `httparchive.pages.2020_08_01_*`
    )
join
    (
        select _table_suffix as client, url
        from `httparchive.technologies.2020_08_01_*`
        where category = 'Ecommerce'
    )
    using(client, url)
group by client
