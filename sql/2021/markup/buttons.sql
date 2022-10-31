# standardSQL
# pages markup metrics grouped by device and button type
# returns button struct
create temporary function get_markup_buttons_info(markup_string string)
returns
    array<
        struct<
            name string,
            freq int64 >> language js
            as
                '''
var result = [];
try {
    var markup = JSON.parse(markup_string);

    if (Array.isArray(markup) || typeof markup != 'object') return result;

    if (markup.buttons && markup.buttons.types) {
      var total = markup.buttons.total;
      var withType = 0;
      result = Object.entries(markup.buttons.types).map(([name, freq]) => { withType+=freq; return  {name: name.toLowerCase().trim(), freq};});

      result.push({name:"NO_TYPE", freq: total - withType})

      return result;
    }

} catch (e) {}
return result;
'''
;

select
    _table_suffix as client,
    button_type_info.name as button_type,
    countif(button_type_info.freq > 0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    countif(button_type_info.freq > 0)
    / sum(count(0)) over (partition by _table_suffix) as pct_page_with_button_type
from
    `httparchive.pages.2021_07_01_*`,
    unnest(
        get_markup_buttons_info(json_extract_scalar(payload, '$._markup'))
    ) as button_type_info
group by client, button_type
order by pct_page_with_button_type desc, client, freq desc
limit 1000
