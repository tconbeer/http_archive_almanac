# standardSQL
# Subresource integrity: hash function usage
with
    totals as (
        select _table_suffix as client, count(0) as total_sri_elements
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(
                json_extract_array(
                    json_extract_scalar(payload, '$._security'), '$.sri-integrity'
                )
            ) as sri
        group by client
    )

select
    client,
    hash_function,
    total_sri_elements,
    count(0) as freq,
    count(0) / total_sri_elements as pct
from
    (
        select
            _table_suffix as client,
            json_extract_array(
                json_extract_scalar(payload, '$._security'), '$.sri-integrity'
            ) as sris
        from `httparchive.pages.2021_07_01_*`
    ),
    unnest(sris) as sri,
    unnest(
        regexp_extract_all(json_extract_scalar(sri, '$.integrity'), r'(sha[^-]+)-')
    ) as hash_function
join totals using(client)
where sri is not null
group by client, total_sri_elements, hash_function
order by client, pct desc
