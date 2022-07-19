# standardSQL
# CSS in JS. Show number of sites that using each framework or not using any.
create temporary function getcssinjs(payload string)
returns array
< string
> language js
as '''
  try {
    var $ = JSON.parse(payload);
    var css = JSON.parse($._css);

    return css && Array.isArray(css.css_in_js) && css.css_in_js.length > 0 ? css.css_in_js : ['NONE'];
  } catch (e) {
    return ['Error:' + e.message];
  }
'''
;

select
    cssinjs,
    count(0) as freq,
    sum(count(0)) over () as total,
    count(0) / sum(count(0)) over () as pct
from
    (
        select url, cssinjs
        from `httparchive.sample_data.pages_mobile_10k`
        cross join unnest(getcssinjs(payload)) as cssinjs
    )
where cssinjs != 'NONE'
group by cssinjs
order by freq
