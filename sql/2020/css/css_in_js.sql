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

    if (!Array.isArray(css.css_in_js)) {
      return [];
    }

    // Use a safe-list to avoid parse error garbage.
    var frameworks = new Set([
      "Styled Components",
      "Radium",
      "React JSS",
      "Emotion",
      "Goober",
      "Merge Styles",
      "Styled Jsx",
      "Aphrodite",
      "Fela",
      "Styletron",
      "React Native for Web",
      "Glamor"
    ]);

    return css.css_in_js.filter(i => frameworks.has(i));
  } catch (e) {
    return [];
  }
'''
;

select
    client,
    cssinjs,
    count(distinct url) as pages,
    total,
    count(distinct url) / total as pct
from
    (
        select _table_suffix as client, url, cssinjs
        from `httparchive.pages.2020_08_01_*`, unnest(getcssinjs(payload)) as cssinjs
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
    )
    using(client)
group by client, cssinjs, total
order by pct desc
