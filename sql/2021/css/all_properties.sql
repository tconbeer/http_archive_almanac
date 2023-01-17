# standardSQL
create temporary function getproperties(css string)
returns array<string>
language js
options (library = "gs://httparchive/lib/css-utils.js")
as '''
try {
  function compute(ast) {
    let ret = {};

    walkDeclarations(ast, ({property, value}) => {
      if (!property.startsWith("--")) { // Custom props are case sensitive
        property = property.toLowerCase();
      }

      incrementByKey(ret, property);
    });

    return sortObject(ret);
  }

  let ast = JSON.parse(css);
  let props = compute(ast);
  return Object.entries(props).flatMap(([prop, freq]) => {
    return Array(freq).fill(prop);
  });
}
catch (e) {
  return [];
}
'''
;

select *
from
    (
        select
            client,
            prop,
            count(distinct page) as pages,
            count(0) as freq,
            sum(count(0)) over (partition by client) as total,
            count(0) / sum(count(0)) over (partition by client) as pct
        from `httparchive.almanac.parsed_css`, unnest(getproperties(css)) as prop
        where date = '2021-07-01'
        group by client, prop
    )
where pages >= 1000
order by pct desc
