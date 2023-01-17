# standardSQL
# 08_25-34: Security headers
select
    _table_suffix as client,
    header,
    countif(regexp_contains(respotherheaders, concat('(?i)', header, ' ='))) as freq,
    total,
    round(
        countif(regexp_contains(respotherheaders, concat('(?i)', header, ' =')))
        * 100
        / total,
        2
    ) as pct
from
    `httparchive.summary_requests.2019_07_01_*`,
    unnest(
        [
            'nel',
            'report-to',
            'referrer-policy',
            'feature-policy',
            'x-content-type-options',
            'x-xss-protection',
            'x-frame-options',
            'cross-origin-resource-policy',
            'cross-origin-opener-policy',
            'sec-fetch-(dest|mode|site|user)',
            'strict-transport-security',
            'content-security-policy'
        ]
    )
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (_table_suffix)
where firsthtml
group by client, total, header
order by freq / total desc
