# standardSQL
# 10_09a: Content - looking at word count, thin pages, header usage, alt attributes
# images
select
    percentile,
    client,
    approx_quantiles(words_count, 1000) [offset (percentile * 10)] as words_count,
    approx_quantiles(word_elements, 1000) [offset (percentile * 10)] as word_elements,
    approx_quantiles(
        header_words_count, 1000) [offset (percentile * 10)
    ] as header_words_count,
    approx_quantiles(
        header_elements, 1000) [offset (percentile * 10)
    ] as header_elements
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
                    "$['seo-words'].wordElements"
                ) as int64
            ) as word_elements,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'),
                    "$['seo-titles'].titleWords"
                ) as int64
            ) as header_words_count,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'),
                    "$['seo-titles'].titleElements"
                ) as int64
            ) as header_elements
        from `httparchive.pages.2019_07_01_*`
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
