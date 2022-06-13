# standardSQL
# Form controls with placeholder but no label
select
    client,
    count(0) as total_sites,
    countif(total_placeholder > 0) as sites_with_placeholder,
    countif(total_no_label > 0) as sites_with_no_label,  # Has placeholder but no label

    countif(total_placeholder > 0) / count(0) as pct_sites_with_placeholder,
    # Sites with placeholders that dont always use labels alongside them
    countif(total_no_label > 0) / countif(
        total_placeholder > 0
    ) as pct_placeholder_sites_with_no_label,

    sum(total_placeholder) as total_placeholders,
    sum(total_no_label) as total_placeholder_with_no_label,
    sum(total_no_label) / sum(total_placeholder) as pct_placeholders_with_no_label
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.placeholder_but_no_label.total_placeholder'
                ) as int64
            ) as total_placeholder,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.placeholder_but_no_label.total_no_label'
                ) as int64
            ) as total_no_label
        from `httparchive.pages.2021_07_01_*`
    )
group by client
