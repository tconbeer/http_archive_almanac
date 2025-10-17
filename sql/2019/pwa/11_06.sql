# standardSQL
# 11_06: beforeinstallprompt usage
select
    client,
    count(distinct page) as freq,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from `httparchive.almanac.summary_response_bodies`
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (client),
    unnest(regexp_extract_all(body, 'beforeinstallprompt'))
where date = '2019-07-01' and (firsthtml or type = 'script')
group by client, total
