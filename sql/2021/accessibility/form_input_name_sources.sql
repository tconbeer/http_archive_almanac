# standardSQL
# Where input elements get their A11Y names from
create temporary function a11yinputnamesources(payload string)
returns array
< string
> language js as '''
  try {
    const a11y = JSON.parse(payload);

    const accessible_name_sources = [];
    for (const tree_node of a11y.form_control_a11y_tree) {
      if (tree_node.type === "button") {
        continue;
      }
      if (tree_node.type === "input" && tree_node.attributes.type === "submit") {
        continue;
      }

      if (tree_node.accessible_name.length === 0) {
        // No A11Y name given
        accessible_name_sources.push("No accessible name");
        continue;
      }

      if (tree_node.accessible_name_sources.length <= 0) {
        continue;
      }

      const name_source = tree_node.accessible_name_sources[0];
      let pretty_name_source = name_source.type;
      if (name_source.type === "attribute") {
        pretty_name_source = `${name_source.type}: ${name_source.attribute}`;
      } else if (name_source.type === "relatedElement") {
        if (name_source.attribute) {
          pretty_name_source = `${name_source.type}: ${name_source.attribute}`;
        } else {
          pretty_name_source = `${name_source.type}: label`;
        }
      }

      accessible_name_sources.push(pretty_name_source);
    }

    return accessible_name_sources;
  } catch (e) {
    return [];
  }
'''
;

select
    client,
    sum(count(0)) over (partition by client) as total_inputs,

    input_name_source,
    count(0) as total_with_this_source,
    count(0) / sum(count(0)) over (partition by client) as perc_of_all_inputs
from
    (
        select _table_suffix as client, input_name_source
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(
                a11yinputnamesources(json_extract_scalar(payload, '$._a11y'))
            ) as input_name_source
    )
group by client, input_name_source
