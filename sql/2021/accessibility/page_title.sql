# standardSQL
# Page title stats (usage, descriptive, changed on render)
select
    client,
    count(0) as total_sites,
    countif(total_title_words > 0) as total_has_title,
    countif(total_title_words > 3) as total_title_with_four_or_more_words,
    countif(title_changed_on_render) as total_title_changed,

    countif(total_title_words > 0) / count(0) as pct_with_title,
    countif(total_title_words > 3) / countif(
        total_title_words > 0
    ) as pct_titles_four_or_more_words,
    countif(title_changed_on_render) / countif(
        total_title_words > 0
    ) as pct_titles_changed_on_render
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._wpt_bodies'),
                    '$.title.title_changed_on_render'
                ) as bool
            ) as title_changed_on_render,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._wpt_bodies'),
                    '$.title.rendered.primary.words'
                ) as int64
            ) as total_title_words
        from `httparchive.pages.2021_07_01_*`
    )
group by client
