# standardSQL
CREATE TEMPORARY FUNCTION getCalcConstants(css STRING)
RETURNS ARRAY<STRING>
LANGUAGE js
OPTIONS (library = "gs://httparchive/lib/css-utils.js")
AS '''
try {
  function compute(ast) {
    let ret = {
      total: 0,
      properties: {},
      units: {},
      number_of_different_units: {},
      operators: {},
      number_of_operators: {},
      number_of_parens: {},
      constants: new Set()
    };

    walkDeclarations(ast, ({property, value}) => {
      for (let calc of extractFunctionCalls(value, {names: "calc"})) {
        incrementByKey(ret.properties, property);
        ret.total++;

        let args = calc.args.replace(/calc\\(/g, "(");

        let units = args.match(/[a-z]+|%/g) || [];
        units.forEach(e => incrementByKey(ret.units, e));
        incrementByKey(ret.number_of_different_units, new Set(units).size);

        let ops = args.match(/[-+\\/*]/g) || [];
        ops.forEach(e => incrementByKey(ret.operators, e));
        incrementByKey(ret.number_of_operators, ops.length);

        let parens = args.match(/\\(/g) || [];
        incrementByKey(ret.number_of_parens, parens.length);

        if (units.length === 0) {
          ret.constants.add(args);
        }
      }
    }, {
      values: /calc\\(/,
      not: {
        values: /var\\(--/
      }
    });

    ret.constants = [...ret.constants];

    for (let type in ret) {
      if (ret[type].constructor === Object) {
        ret[type] = sortObject(ret[type]);
      }
    }

    return ret;
  }
  var ast = JSON.parse(css);
  var calc = compute(ast);
  return calc.constants;
} catch (e) {
  return [];
}
''';

select
    client,
    count(distinct if(const is not null, page, null)) as pages,
    count(distinct page) as total,
    count(distinct if(const is not null, page, null)) / count(distinct page) as pct
from
    (
        select client, page, const
        from `httparchive.almanac.parsed_css`
        left join unnest(getcalcconstants(css)) as const
        # Limit the size of the CSS to avoid OOM crashes.
        where date = '2021-07-01' and length(css) < 0.1 * 1024 * 1024
    )
group by client
