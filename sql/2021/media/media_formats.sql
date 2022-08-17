create temporary function fixformat(format string, mimetype string)
returns string
language js as '''
if (mimeType === "image/avif") {
  return "avif";
} else if (mimeType === "image/webp" || format==="webp") {
  return "webp";
} else {
  return format;
}
'''
;

select
    client,
    trueformat,
    count(distinct net.host(url)) as hosts,
    count(distinct page) as pages,
    count(0) as freqimages,
    sum(count(0)) over (partition by client) as totalimages,
    count(0) / sum(count(0)) over (partition by client) as pctimages
from
    (
        select client, page, url, fixformat(format, mimetype) as trueformat
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and type = 'image' and respsize > 0
    )
group by client, trueformat
order by pctimages desc
