select
    client,
    custom_elements,
    shadow_roots,
    templates,
    total,
    custom_elements / total as pct_custom_elements,
    shadow_roots / total as pct_shadow_roots,
    templates / total as pct_templates
from
    (
        select
            client,
            count(0) as total,
            countif(
                array_length(
                    json_extract_array(js, '$.web_component_specs.custom_elements')
                )
                > 0
            ) as custom_elements,
            countif(
                array_length(
                    json_extract_array(js, '$.web_component_specs.shadow_roots')
                )
                > 0
            ) as shadow_roots,
            countif(
                array_length(json_extract_array(js, '$.web_component_specs.template'))
                > 0
            ) as templates
        from
            (
                select
                    _table_suffix as client,
                    json_extract_scalar(payload, '$._javascript') as js
                from `httparchive.pages.2021_09_01_*`
            )
        group by client
    )
