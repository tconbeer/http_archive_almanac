# standardSQL
CREATE TEMPORARY FUNCTION getSupports(css STRING)
RETURNS ARRAY<STRING>
LANGUAGE js
OPTIONS (library = "gs://httparchive/lib/css-utils.js")
AS '''
try {
  function compute(ast) {
    let ret = {};

    walkRules(ast, rule => {
      incrementByKey(ret, "total");

      let condition = rule.supports;

      // Drop whitespace around parens
      condition = condition.replace(/\\s*\\(\\s*/g, "(").replace(/\\s*\\)\\s*/g, ")");

      // Match property: value queries first
      for (let match of condition.matchAll(/\\([\\w-]+\\s*:/g)) {
        let arg = parsel.gobbleParens(condition, match.index);
        incrementByKey(ret, arg);
      }

      // Then find selector queries
      for (let match of condition.matchAll(/selector\\(/gi)) {
        let arg = parsel.gobbleParens(condition, match.index + match[0].length - 1);
        incrementByKey(ret, "selector" + arg);
      }
    }, {type: "supports"});

    ret = sortObject(ret);

    return ret;
  }

  const ast = JSON.parse(css);
  let supports = compute(ast);
  return Object.entries(supports).filter(([criteria]) => {
    return criteria != 'total';
  }).flatMap(([criteria, freq]) => {
    return new Array(freq).fill(criteria);
  });
} catch (e) {
  return [];
}
''';

select
    client,
    supports,
    count(distinct page) as pages,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from `httparchive.almanac.parsed_css`, unnest(getsupports(css)) as supports
where date = '2021-07-01'
group by client, supports
order by pct desc
limit 300
