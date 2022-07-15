select
    _table_suffix as client,
    avg(bytestotal) / 1024 as total_kbytes,
    avg(byteshtml) / 1024 as html_kbytes,
    avg(bytesjs) / 1024 as js_kbytes,
    avg(bytescss) / 1024 as css_kbytes,
    avg(bytesimg) / 1024 as img_kbytes,
    avg(bytesother) / 1024 as other_kbytes,
    avg(byteshtmldoc) / 1024 as html_doc_kbytes,
    avg(bytesfont) / 1024 as font_kbytes
from `httparchive.summary_pages.2021_07_01_*`
group by client
