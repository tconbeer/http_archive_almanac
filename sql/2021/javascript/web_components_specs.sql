select
    client,
    percentile,
    approx_quantiles(custom_elements, 1000)[offset(percentile * 10)] as custom_elements,
    approx_quantiles(shadow_roots, 1000)[offset(percentile * 10)] as shadow_roots,
    approx_quantiles(template, 1000)[offset(percentile * 10)] as template
from
    (
        select
            _table_suffix as client,
            array_length(
                json_extract_array(
                    json_extract_scalar(payload, '$._javascript'),
                    '$.web_component_specs.custom_elements'
                )
            ) as custom_elements,
            array_length(
                json_extract_array(
                    json_extract_scalar(payload, '$._javascript'),
                    '$.web_component_specs.shadow_roots'
                )
            ) as shadow_roots,
            array_length(
                json_extract_array(
                    json_extract_scalar(payload, '$._javascript'),
                    '$.web_component_specs.template'
                )
            ) as template
        from
            # Note: We're intentionally querying the September dataset here because of
            # a bug in the custom metric.
            # See https://github.com/HTTPArchive/legacy.httparchive.org/pull/231.
            `httparchive.pages.2021_09_01_*`
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
