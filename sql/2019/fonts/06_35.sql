# standardSQL
# 06_35: Pages using the most fonts
select _table_suffix as client, reqfont as fonts, url
from `httparchive.summary_pages.2019_07_01_*`
join
    (
        select _table_suffix, max(reqfont) as reqfont
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    )
    using
    (_table_suffix, reqfont)
order by fonts desc
