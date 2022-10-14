# standardSQL
# 10_11: Linking - fragment URLs (together with SPAs to navigate content)
select
    _table_suffix as client,
    app,
    countif(navigate_hash) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    round(
        countif(navigate_hash) * 100 / sum(count(0)) over (partition by _table_suffix),
        2
    ) as pct
from
    (
        select
            _table_suffix,
            url,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'),
                    "$['seo-anchor-elements'].navigateHash"
                ) as int64
            )
            > 0 as navigate_hash
        from `httparchive.pages.2019_07_01_*`
    )
join `httparchive.technologies.2019_07_01_*` using (_table_suffix, url)
where app in ('React', 'Angular', 'Vue.js')
group by client, app
order by freq / total desc
