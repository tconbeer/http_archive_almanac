# standardSQL
# 08_23-24b: Chrome preload eligiblity: max-age >= 1 year, includeSubdomains, preload
select
    _table_suffix as client,
    count(0) as freq,
    total,
    round(count(0) * 100 / total, 2) as pct
from
    (
        select
            _table_suffix,
            regexp_extract(
                respotherheaders, r'(?i)\W?strict-transport-security =([^,]+)'
            ) as hsts
        from `httparchive.summary_requests.2019_07_01_*`
        where firsthtml
    )
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    )
    using(_table_suffix)
where
    hsts is not null and cast(
        regexp_extract(hsts, r'(?i)max-age= *(-?\d+)') as int64
    ) >= 31536000 and regexp_contains(hsts, 'includeSubdomains') and
    regexp_contains(hsts, 'preload')
group by client, total
