# standardSQL
# % sites with links to to the same page, # or javascript:void
# NOTE: same_page.total includes empty hash links (#) but excludes all others (#foobar)
select
    client,
    count(0) as total_sites,
    countif(total_anchors > 0) as sites_with_anchors,

    countif(same_page > 0) as has_same_page,
    countif(hash_only > 0) as has_hash_only_link,
    countif(javascript_void > 0) as has_javascript_void_links,

    countif(same_page > 0) / countif(total_anchors > 0) as pct_has_same_page,
    countif(hash_only > 0) / countif(total_anchors > 0) as pct_has_hash_only_link,
    countif(javascript_void > 0)
    / countif(total_anchors > 0) as pct_has_javascript_void_links
from
    (
        select
            _table_suffix as client,

            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._wpt_bodies'),
                    '$.anchors.rendered.same_page.total'
                ) as int64
            ) as same_page,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._wpt_bodies'),
                    '$.anchors.rendered.hash_only_link'
                ) as int64
            ) as hash_only,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._wpt_bodies'),
                    '$.anchors.rendered.javascript_void_links'
                ) as int64
            ) as javascript_void,
            ifnull(
                cast(
                    json_extract_scalar(
                        json_extract_scalar(payload, '$._element_count'), '$.a'
                    ) as int64
                ),
                0
            ) as total_anchors
        from `httparchive.pages.2021_07_01_*`
    )
group by client
