# standardSQL
# 18_01c: Average size of each of the resource types.
select
    _table_suffix as client,
    round(avg(bytestotal) / 1024, 2) as total_kbytes,
    round(avg(byteshtml) / 1024, 2) as html_kbytes,
    round(avg(bytesjs) / 1024, 2) as js_kbytes,
    round(avg(bytescss) / 1024, 2) as css_kbytes,
    round(avg(bytesimg) / 1024, 2) as img_kbytes,
    round(avg(bytesother) / 1024, 2) as other_kbytes,
    round(avg(byteshtmldoc) / 1024, 2) as html_doc_kbytes
from `httparchive.summary_pages.2019_07_01_*`
group by client
