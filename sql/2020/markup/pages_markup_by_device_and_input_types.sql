# standardSQL
# pages markup metrics grouped by device and input type
# helper to create percent fields
create temp function as_percent(freq float64, total float64) returns float64 as (
    round(safe_divide(freq, total), 4)
)
;

# returns all the data we need from _markup
create temporary function get_markup_inputs_info(markup_string string)
returns array < struct < name string,
freq int64
>> language js
as '''
var result = [];
try {
    var markup = JSON.parse(markup_string);

    if (Array.isArray(markup) || typeof markup != 'object') return result;

    if (markup.inputs && markup.inputs.types) {
      var total = markup.inputs.total;
      var withType = 0;
      result = Object.entries(markup.inputs.types).map(([name, freq]) => { withType+=freq; return  {name: name.toLowerCase().trim(), freq};});

      result.push({name:"NO_TYPE", freq: total - withType})

      return result;
    }

} catch (e) {}
return result;
'''
;

select
    _table_suffix as client,
    markup_input_info.name as input_type,
    countif(markup_input_info.freq > 0) as freq_page_with_input,
    as_percent(countif(markup_input_info.freq > 0), total) as pct_page_with_input,
    sum(markup_input_info.freq) as freq_input,
    as_percent(
        sum(markup_input_info.freq),
        sum(sum(markup_input_info.freq)) over (partition by _table_suffix)
    ) as pct_input
from `httparchive.pages.2020_08_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2020_08_01_*`
        # to get an accurate total of pages per device. also seems fast
        group by _table_suffix
    ) using (_table_suffix),
    unnest(
        get_markup_inputs_info(json_extract_scalar(payload, '$._markup'))
    ) as markup_input_info
group by client, input_type, total
order by freq_page_with_input desc
limit 1000
