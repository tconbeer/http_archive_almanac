# standardSQL
# 13_02: % of eCommerce tagged sites by device
# # Carry 2019 and 2020 data in run
# # This query is built using 2019 query from
# https://github.com/HTTPArchive/almanac.httparchive.org/blob/main/sql/2019/13_Ecommerce/13_02b.sql but this commit fixes a flaw in 2019 query. See - https://github.com/HTTPArchive/almanac.httparchive.org/issues/1810
select
    _table_suffix as client,
    2020 as year,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from `httparchive.technologies.2020_08_01_*`
join
    (
        select _table_suffix, count(distinct url) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by _table_suffix
    ) using (_table_suffix)
where category = 'Ecommerce'
group by client, total
union all
select
    _table_suffix as client,
    2019 as year,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from `httparchive.technologies.2019_07_01_*`
join
    (
        select _table_suffix, count(distinct url) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (_table_suffix)
where category = 'Ecommerce'
group by client, total
