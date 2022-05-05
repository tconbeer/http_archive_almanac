# standardSQL
# page almanac metrics grouped by device and html dir
# returns all the data we need from _almanac
create temporary function get_almanac_html_dir(almanac_string string)
returns string language js
as '''
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return '';

    if (almanac.html_node && almanac.html_node.dir) {
      return almanac.html_node.dir.trim().toLowerCase();
    }

} catch (e) {}
return '';
'''
;

select
    client,
    count(0) as freq,
    almanac_html_dir as html_dir,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            _table_suffix as client,
            get_almanac_html_dir(
                json_extract_scalar(payload, '$._almanac')
            ) as almanac_html_dir
        from `httparchive.pages.2021_07_01_*`
    )
group by client, html_dir
order by client, freq desc
