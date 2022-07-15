# standardSQL
create temporary function getmediaqueryproperties(css string)
returns array < string > language js
options(library = "gs://httparchive/lib/css-utils.js") as '''
try {
  function compute(ast) {
    let ret = {};

    walkRules(ast, rule => {
      walkDeclarations(rule.rules, ({property, value}) => {
        incrementByKey(ret, property);
      });
    }, {
      type: "media"
    });

    return sortObject(ret);
  }

  const ast = JSON.parse(css);
  let properties = compute(ast);
  return Object.keys(properties);
} catch (e) {
  return [];
}
'''
;

select
    client,
    property,
    count(distinct page) as pages,
    total,
    count(distinct page) / total as pct
from
    (
        select distinct client, page, lower(property) as property
        from `httparchive.almanac.parsed_css`
        left join unnest(getmediaqueryproperties(css)) as property
        where date = '2020-08-01' and property is not null
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
    )
    using
    (client)
group by client, total, property
having pct >= 0.01
order by pct desc
