# standardSQL
# 08_23-24: HSTS subdomains and preload usage
select
    _table_suffix as client,
    directive,
    count(0) as freq,
    total,
    round(count(0) * 100 / total, 2) as pct
from
    `httparchive.summary_requests.2019_07_01_*`,
    unnest(
        regexp_extract_all(
            regexp_extract(
                respotherheaders, r'(?i)\W?strict-transport-security =([^,]+)'
            ),
            '(max-age|includeSubDomains|preload)'
        )
    ) as directive
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    )
    using(_table_suffix)
where firsthtml
group by client, total, directive
order by freq / total desc
