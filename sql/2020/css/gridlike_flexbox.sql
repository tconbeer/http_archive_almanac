# standardSQL
create temporary function hasgridlikeflexbox(css string)
returns boolean
language js
options(library = "gs://httparchive/lib/css-utils.js")
as '''
try {
  const ast = JSON.parse(css);
  return walkRules(ast, rule => {
    let d = Object.fromEntries(rule.declarations.map(d => [d.property, d.value]));

    if (d["flex-grow"] === "0" && d["flex-shrink"] === "0" || /^0 0($|\\s)/.test(d.flex)) {
      if (/%$/.test(d["flex-basis"]) || /%$/.test(d.flex) || /%$/.test(d.width) && (!d["flex-basis"] || d["flex-basis"] === "auto")) {
        return true; // break
      }
    }
  }, {type: "rule"}) || false;
} catch (e) {
  return false;
}
'''
;

select
    client,
    countif(gridlike_flexbox) as pages_with_gridlike_flexbox,
    total,
    countif(gridlike_flexbox) / total as pct
from
    (
        select client, page, countif(hasgridlikeflexbox(css)) > 0 as gridlike_flexbox
        from `httparchive.almanac.parsed_css`
        where date = '2020-08-01'
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
    ) using (client)
group by client, total
