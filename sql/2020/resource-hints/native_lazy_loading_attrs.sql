# standardSQL
# 21_12b: Values of the 'loading' attribute
select
    _table_suffix as client,
    loading,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from
    `httparchive.pages.2020_08_01_*`,
    unnest(
        json_extract_array(json_extract_scalar(payload, "$['_img-loading-attr']"), '$')
    ) as loading
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2020_08_01_*`
        group by _table_suffix
    ) using (_table_suffix)
group by client, loading, total
having freq >= 10
order by freq desc
