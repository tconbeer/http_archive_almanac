# standardSQL
# 10_18: Zero count words and headers
select
    client,
    round(
        countif(words_count = 0) * 100 / sum(count(0)) over (partition by client), 2
    ) as word_count_zero,
    round(
        countif(header_elements = 0) * 100 / sum(count(0)) over (partition by client), 2
    ) as header_count_zero
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'),
                    "$['seo-words'].wordsCount"
                ) as int64
            ) as words_count,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'),
                    "$['seo-titles'].titleElements"
                ) as int64
            ) as header_elements
        from `httparchive.pages.2019_07_01_*`
    )
group by client
