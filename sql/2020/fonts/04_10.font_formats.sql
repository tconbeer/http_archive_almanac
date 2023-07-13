# standardSQL
# font_formats
select
    client,
    lower(ifnull(regexp_extract(mimetype, '/(?:x-)?(?:font-)?(.*)'), ext)) as mime_type,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from `httparchive.almanac.requests`
where type = 'font' and mimetype != '' and date = '2020-08-01'
group by client, mime_type
order by client, pct desc
