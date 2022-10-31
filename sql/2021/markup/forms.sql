# standardSQL
# pages markup metrics grouped by device and form type
# returns number of forms
create temporary function get_forms_count(markup_string string)
returns int64
language js
as '''
try {
  var markup = JSON.parse(markup_string);

  if (Array.isArray(markup) || typeof markup != 'object') return null;

  return markup.form || 0;
} catch (e) {
  return 0;
}
'''
;

select
    client,
    forms_count,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct_page_with_form
from
    (
        select
            _table_suffix as client,
            get_forms_count(
                json_extract_scalar(payload, '$._element_count')
            ) as forms_count
        from `httparchive.pages.2021_07_01_*`
    )
group by client, forms_count
order by client, forms_count
