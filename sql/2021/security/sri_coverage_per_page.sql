# standardSQL
# Subresource integrity: percentage of scripts on a page that have the integrity
# attribute
create temp function getnumscriptelements(sris array < string >) as (
    (
        select count(0)
        from unnest(sris) as sri
        where json_extract_scalar(sri, '$.tagname') = 'script'
    )
)
;

select
    client,
    percentile,
    approx_quantiles(getnumscriptelements(sris) / num_scripts, 1000 ignore nulls) [
        offset (percentile * 10)
    ] as integrity_pct
from
    (
        select
            _table_suffix as client,
            json_extract_array(
                json_extract_scalar(payload, '$._security'), '$.sri-integrity'
            ) as sris,
            safe_cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._element_count'), '$.script'
                ) as int64
            ) as num_scripts
        from `httparchive.pages.2021_07_01_*`
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
where getnumscriptelements(sris) > 0
group by client, percentile
order by client, percentile
