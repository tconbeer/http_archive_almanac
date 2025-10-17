# standardSQL
# Most common lengths of alt text
# Note: A value of -1 means there is no alt tag. 0 means it is empty
# Note: Lengths of 2000+ characters are grouped together
select
    client,
    sum(count(0)) over (partition by client) as total_images,
    sum(countif(alt_length_clipped >= 0)) over (partition by client) as total_alt_tags,

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
                    `httparchive.pages.2021_07_01_*`,
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
order by alt_length asc
