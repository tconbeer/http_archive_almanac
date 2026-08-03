# standardSQL
# How often the title attribute is used with an alt attribute, and how often they are
# the same values
select
    client,
    sum(total_alt) as total_alts,
    sum(total_title) as total_titles,
    sum(total_both) as total_both,
    sum(total_alt_same_as_title) as total_alt_same_as_title,
    sum(total_both) / sum(total_alt) as pct_title_used_with_alt,
    sum(total_alt_same_as_title) / sum(total_both) as pct_same_when_both_used,
    sum(total_alt_same_as_title) / sum(total_alt) as pct_same_of_all_alts
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'), '$.title_and_alt.total_alt'
                ) as int64
            ) as total_alt,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.title_and_alt.total_title'
                ) as int64
            ) as total_title,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.title_and_alt.total_both'
                ) as int64
            ) as total_both,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._a11y'),
                    '$.title_and_alt.total_alt_same_as_title'
                ) as int64
            ) as total_alt_same_as_title
        from `httparchive.pages.2020_08_01_*`
    )
group by client
