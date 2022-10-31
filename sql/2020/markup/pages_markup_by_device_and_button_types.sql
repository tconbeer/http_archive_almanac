# standardSQL
# pages markup metrics grouped by device and button type
# helper to create percent fields
create temp function as_percent(freq float64, total float64)
returns float64
as (round(safe_divide(freq, total), 4))
;

# returns all the data we need from _markup
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
    countif(button_type_info.freq > 0) as freq_page_with_button,
    as_percent(countif(button_type_info.freq > 0), total) as pct_page_with_button,
    sum(button_type_info.freq) as freq_button,
    as_percent(
        sum(button_type_info.freq),
        sum(sum(button_type_info.freq)) over (partition by _table_suffix)
    ) as pct_button
from `httparchive.pages.2020_08_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2020_08_01_*`
        # to get an accurate total of pages per device. also seems fast
        group by _table_suffix
    ) using (_table_suffix),
    unnest(
        get_markup_buttons_info(json_extract_scalar(payload, '$._markup'))
    ) as button_type_info
group by client, button_type, total
order by freq_page_with_button desc
limit 1000
