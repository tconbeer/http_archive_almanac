# standardSQL
# Disabled zooming and scaling via the viewport tag by domain rank
select
    client,
    rank_grouping,

    count(0) as total_pages,
    countif(has_meta_viewport) as total_viewports,
    countif(not_scalable) as total_no_scale,
    countif(max_scale_1_or_less) as total_locked_max_scale,
    countif(not_scalable or max_scale_1_or_less) as total_either,

    countif(not_scalable) / count(0) as pct_pages_no_scale,
    countif(max_scale_1_or_less) / count(0) as pct_pages_locked_max_scale,
    countif(not_scalable or max_scale_1_or_less) / count(0) as pct_pages_either
from
    (
        select
            client,
            url,
            meta_viewport is not null as has_meta_viewport,
            regexp_extract(
                meta_viewport, r'(?i)user-scalable\s*=\s*(no|0)'
            ) is not null as not_scalable,
            safe_cast(
                regexp_extract(
                    meta_viewport, r'(?i)maximum-scale\s*=\s*([0-9]*\.[0-9]+|[0-9]+)'
                ) as float64
            ) <= 1 as max_scale_1_or_less
        from
            (
                select
                    _table_suffix as client,
                    url,
                    json_extract_scalar(payload, '$._meta_viewport') as meta_viewport
                from `httparchive.pages.2021_07_01_*`
            )
    )
left join
    (
        select _table_suffix as client, url, rank_grouping
        from
            `httparchive.summary_pages.2021_07_01_*`,
            unnest( [1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where rank <= rank_grouping
    ) using(client, url)
group by rank_grouping, client
