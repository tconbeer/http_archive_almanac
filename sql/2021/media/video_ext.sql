select _table_suffix as client, ext, count(ext) as cnt
from `httparchive.summary_requests.2021_07_01_*`
where mimetype like '%video%'
group by client, ext
order by cnt desc
