# standardSQL
# 06_03: counts the font types (format)
select
    client,
    lower(ifnull(regexp_extract(mimetype, '/(?:x-)?(?:font-)?(.*)'), ext)) as mime_type,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.requests`
where date = '2019-07-01' and type = 'font'
group by client, mime_type
order by freq / total desc
