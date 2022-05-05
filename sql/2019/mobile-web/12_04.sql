# standardSQL
# 12_04: Sites that disable zooming and scaling via the viewport tag
select
    client,
    count(0) as total_sites,
    countif(has_meta_viewport) as total_viewports,
    countif(not_scalable) as total_no_scale,
    countif(max_scale_1_or_less is true) as total_locked_max_scale,
    countif(not_scalable or (max_scale_1_or_less is true)) as total_either,

    round(countif(not_scalable) * 100 / count(0), 2) as perc_sites_no_scale,
    round(
        countif(max_scale_1_or_less is true) * 100 / count(0), 2
    ) as perc_sites_locked_max_scale,
    round(
        countif(not_scalable or (max_scale_1_or_less is true)) * 100 / count(0), 2
    ) as perc_sites_either
from
    (
        select
            client,
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
                    json_extract_scalar(payload, '$._meta_viewport') as meta_viewport
                from `httparchive.pages.2019_07_01_*`
            )
    )
group by client
