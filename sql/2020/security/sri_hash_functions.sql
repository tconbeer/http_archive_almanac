# standardSQL
# Subresource integrity: hash function usage
select
    client,
    hash_function,
    sum(count(0)) over (partition by client) as total_sri_elements,
    count(0) as freq,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            _table_suffix as client,
            json_extract_array(
                json_extract_scalar(payload, '$._security'), '$.sri-integrity'
            ) as sris
        from `httparchive.pages.2020_08_01_*`
    ),
    unnest(sris) as sri,
    unnest(
        regexp_extract_all(json_extract_scalar(sri, '$.integrity'), r'(sha[^-]+)-')
    ) as hash_function
where sri is not null
group by client, hash_function
order by client, pct desc
