# standardSQL
# 04_16: Pages self-serving video
select
    client,
    count(distinct page) as pages,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from `httparchive.almanac.requests`
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (client)
where
    date = '2019-07-01'
    and type = 'video'
    and net.reg_domain(url) not in (
        'youtube.com',
        'youtube-nocookie.com',
        'googlevideo.com',
        'fbcdn.net',
        'vimeocdn.com'
    )
group by client, total
