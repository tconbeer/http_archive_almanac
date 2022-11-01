# standardSQL
# page almanac metrics grouped by device and html lang
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
    if(
        ifnull(trim(almanac_html_lang), '') = '', '(not set)', almanac_html_lang
    ) as html_lang_country,
    if(
        ifnull(
            trim(
                substr(
                    almanac_html_lang,
                    0,
                    length(almanac_html_lang) - strpos(almanac_html_lang, '-')
                )
            ),
            ''
        )
        = '',
        '(not set)',
        substr(
            almanac_html_lang,
            0,
            length(almanac_html_lang) - strpos(almanac_html_lang, '-')
        )
    ) as html_lang,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            _table_suffix as client,
            get_almanac_html_lang(
                json_extract_scalar(payload, '$._almanac')
            ) as almanac_html_lang
        from `httparchive.pages.2021_07_01_*`
    )
group by client, almanac_html_lang
order by pct desc, client, freq desc
