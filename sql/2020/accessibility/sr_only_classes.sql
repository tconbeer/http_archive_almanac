# standardSQL
# Sites using sr-only or visually-hidden classes
select
    client,
    count(0) as total_sites,
    countif(uses_sr_only) as sites_with_sr_only,
    countif(uses_sr_only) / count(0) as pct_sites_with_sr_only
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'), '$.screen_reader_classes'
                ) as bool
            ) as uses_sr_only
        from `httparchive.pages.2020_08_01_*`
    )
group by client
