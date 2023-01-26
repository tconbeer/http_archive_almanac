# standardSQL
# Anchors with role='button'
select
    client,
    countif(total_anchors > 0) as sites_with_anchors,
    countif(total_anchors_with_role_button > 0) as sites_with_anchor_role_button,

    # Of sites that have anchors... how many have an anchor with a role='button'
    countif(total_anchors_with_role_button > 0)
    / countif(total_anchors > 0) as pct_sites_with_anchor_role_button
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.total_anchors_with_role_button'
                ) as int64
            ) as total_anchors_with_role_button,
            ifnull(
                cast(
                    json_extract_scalar(
                        json_extract_scalar(payload, '$._element_count'), '$.a'
                    ) as int64
                ),
                0
            ) as total_anchors
        from `httparchive.pages.2020_08_01_*`
    )
group by client
