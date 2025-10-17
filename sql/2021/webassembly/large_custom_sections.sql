select
    any_value(url) as url,
    any_value(size.custom) as custom_sections_size,
    array_to_string(any_value(custom_sections), ', ') as custom_sections
from `httparchive.almanac.wasm_stats`
where date = '2021-09-01' and size.custom > 0
group by filename
order by custom_sections_size desc
