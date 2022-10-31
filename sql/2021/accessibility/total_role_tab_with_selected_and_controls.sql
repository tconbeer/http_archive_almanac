# standardSQL
# Sites containing elements with role='tab', aria-selected and aria-controls attributes
select
    client,
    count(0) as total_sites,

    countif(total_tab_selected_controls > 0) as total_with_tab_selected_controls,
    countif(total_tab_selected_controls > 0)
    / count(0) as pct_with_tab_selected_controls
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.total_role_tab_with_selected_and_controls'
                ) as int64
            ) as total_tab_selected_controls
        from `httparchive.pages.2021_07_01_*`
    )
group by client
