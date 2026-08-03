# standardSQL
# 10_19: Zero count of type of link
select
    client,
    round(
        countif(internal = 0) * 100 / sum(count(0)) over (partition by client), 2
    ) as internal_link_zero,
    round(
        countif(external = 0) * 100 / sum(count(0)) over (partition by client), 2
    ) as external_link_zero,
    round(
        countif(_hash = 0) * 100 / sum(count(0)) over (partition by client), 2
    ) as _hash_link_zero
from
    (
        select
            client,
            cast(
                json_extract_scalar(
                    almanac, "$['seo-anchor-elements'].internal"
                ) as int64
            ) as internal,
            cast(
                json_extract_scalar(
                    almanac, "$['seo-anchor-elements'].external"
                ) as int64
            ) as external,
            cast(
                json_extract_scalar(almanac, "$['seo-anchor-elements'].hash") as int64
            ) as _hash
        from
            (
                select
                    _table_suffix as client,
                    json_extract_scalar(payload, '$._almanac') as almanac
                from `httparchive.pages.2019_07_01_*`
            )
    )
group by client
order by client
