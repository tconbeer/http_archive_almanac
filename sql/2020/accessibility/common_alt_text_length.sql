# standardSQL
# Most common lengths of alt text (-1 for none. 2000+ grouped together)
select
    client,
    sum(count(0)) over (partition by client) as total_alt_tags,

    alt_length_clipped as alt_length,
    count(0) as occurrences,
    count(0) / sum(count(0)) over (partition by client) as pct_all_occurrences
from
    (
        select client, least(alt_length, 2000) as alt_length_clipped
        from
            (
                select
                    _table_suffix as client,
                    safe_cast(alt_length_string as int64) as alt_length
                from
                    `httparchive.pages.2020_08_01_*`,
                    unnest(
                        json_extract_array(
                            json_extract_scalar(payload, '$._almanac'),
                            '$.images.alt_lengths'
                        )
                    ) as alt_length_string
            )
        where alt_length is not null
    )
group by client, alt_length
having occurrences >= 100
order by alt_length asc
