# standardSQL
# Pages with the longest alts
select client, url, largest_alt, alt_rank
from
    (
        select
            _table_suffix as client,
            url,
            max(safe_cast(alt_length_string as int64)) as largest_alt,
            row_number() over (
                partition by _table_suffix
                order by max(safe_cast(alt_length_string as int64)) desc
            ) as alt_rank
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(
                json_extract_array(
                    json_extract_scalar(payload, '$._almanac'), '$.images.alt_lengths'
                )
            ) as alt_length_string
        group by client, url
    )
where alt_rank <= 100
order by alt_rank asc
