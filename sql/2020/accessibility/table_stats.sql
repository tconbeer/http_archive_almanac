# standardSQL
# Table stats. Total all, captioned and presentational
select
    client,
    count(0) as total_sites,

    countif(total_tables > 0) as sites_with_table,
    countif(total_captioned > 0) as sites_with_captions,
    countif(total_presentational > 0) as sites_with_presentational,

    countif(total_tables > 0) / count(0) as pct_sites_with_table,
    countif(total_captioned > 0)
    / countif(total_tables > 0) as pct_table_sites_with_captioned,
    countif(total_presentational > 0)
    / countif(total_tables > 0) as pct_table_sites_with_presentational,

    sum(total_tables) as total_tables,
    sum(total_captioned) as total_captioned,
    sum(total_presentational) as total_presentational,

    sum(total_captioned) / sum(total_tables) as pct_all_captioned,
    sum(total_presentational) / sum(total_tables) as pct_all_presentational
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'), '$.tables.total'
                ) as int64
            ) as total_tables,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.tables.total_with_caption'
                ) as int64
            ) as total_captioned,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.tables.total_with_presentational'
                ) as int64
            ) as total_presentational
        from `httparchive.pages.2020_08_01_*`
    )
group by client
