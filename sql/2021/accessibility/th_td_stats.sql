# standardSQL
# th and td stats. Scope and headers usage
select
    client,
    count(0) as total_sites,
    countif(total_tables > 0) as sites_with_table,
    countif(total_th > 0) as sites_with_th,
    countif(total_td > 0) as sites_with_td,
    countif(total_th_with_scope > 0) as sites_with_th_scope,
    countif(total_td_with_headers > 0) as sites_with_td_headers,

    countif(total_tables > 0) / count(0) as pct_sites_with_table,
    countif(total_th > 0) / count(0) as pct_sites_with_th,
    countif(total_td > 0) / count(0) as pct_sites_with_td,

    countif(total_th_with_scope > 0) / countif(total_th > 0) as pct_th_sites_with_scope,
    countif(total_td_with_headers > 0) / countif(
        total_td > 0
    ) as pct_td_sites_with_headers
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
                    '$.th_with_scope_attribute.total_th'
                ) as int64
            ) as total_th,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.th_with_scope_attribute.total_with_scope'
                ) as int64
            ) as total_th_with_scope,

            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.td_with_headers_attribute.total_tds'
                ) as int64
            ) as total_td,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.td_with_headers_attribute.total_with_headers'
                ) as int64
            ) as total_td_with_headers
        from `httparchive.pages.2021_07_01_*`
    )
group by client
