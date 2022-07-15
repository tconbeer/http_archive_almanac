# standardSQL
# beforeinstallprompt usage - based on 2019/14_06.sql
select client, count(distinct page) as freq, total, count(distinct page) / total as pct
from `httparchive.almanac.summary_response_bodies`
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by _table_suffix
    )
    using(client),
    unnest(regexp_extract_all(body, 'beforeinstallprompt'))
where date = '2020-08-01' and (firsthtml or type = 'script')
group by client, total
