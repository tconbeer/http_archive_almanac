# standardSQL
# Divs or spans with role of button or link
select
    client,
    count(0) as total_sites,
    countif(total_role_button > 0) as sites_with_div_span_role_button,
    countif(total_role_link > 0) as sites_with_div_span_role_link,
    countif(total_either > 0) as sites_with_div_span_role_either,

    countif(total_role_button > 0) / count(0) as pct_sites_with_div_span_role_button,
    countif(total_role_link > 0) / count(0) as pct_sites_with_div_span_role_link,
    countif(total_either > 0) / count(0) as pct_sites_with_div_span_role_either,

    sum(total_role_button) as total_div_span_role_button,
    sum(total_role_link) as total_div_span_role_link,
    sum(total_either) as total_div_span_role_either
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.divs_or_spans_as_button_or_link.total_role_button'
                ) as int64
            ) as total_role_button,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.divs_or_spans_as_button_or_link.total_role_link'
                ) as int64
            ) as total_role_link,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.divs_or_spans_as_button_or_link.total_either'
                ) as int64
            ) as total_either
        from `httparchive.pages.2020_08_01_*`
    )
group by client
