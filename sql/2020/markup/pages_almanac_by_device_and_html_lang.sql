# standardSQL
# page almanac metrics grouped by device and html lang
# helper to create percent fields
CREATE TEMP FUNCTION AS_PERCENT (freq FLOAT64, total FLOAT64) RETURNS FLOAT64 AS (
  ROUND(SAFE_DIVIDE(freq, total), 4)
);

# returns all the data we need from _almanac
CREATE TEMPORARY FUNCTION get_almanac_html_lang(almanac_string STRING)
RETURNS STRING LANGUAGE js AS '''
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return '';

    if (almanac.html_node && almanac.html_node.lang) {
      return almanac.html_node.lang.trim().toLowerCase();
    }

} catch (e) {}
return '';
''';

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
