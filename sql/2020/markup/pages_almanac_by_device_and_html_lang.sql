# standardSQL
# page almanac metrics grouped by device and html lang
# helper to create percent fields
create temp function as_percent(freq float64, total float64)
returns float64
as (round(safe_divide(freq, total), 4))
;

# returns all the data we need from _almanac
create temporary function get_almanac_html_lang(almanac_string string)
returns string
language js
as '''
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return '';

    if (almanac.html_node && almanac.html_node.lang) {
      return almanac.html_node.lang.trim().toLowerCase();
    }

} catch (e) {}
return '';
'''
;

select
    client,
    count(0) as freq,
    almanac_html_lang as html_lang,

    as_percent(count(0), sum(count(0)) over (partition by client)) as pct_m405

from
    (
        select
            _table_suffix as client,
            get_almanac_html_lang(
                json_extract_scalar(payload, '$._almanac')
            ) as almanac_html_lang
        from `httparchive.pages.2020_08_01_*`
    )
group by client, html_lang
order by freq desc
