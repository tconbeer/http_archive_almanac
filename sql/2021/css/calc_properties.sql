# standardSQL
create temporary function getcalcproperties(css string)
returns array<struct<name string, freq int64>>
language js
options (library = "gs://httparchive/lib/css-utils.js")
as '''
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
  return Object.entries(calc.properties).map(([name, freq]) => ({name, freq}))
} catch (e) {
  return [];
}
'''
;

select
    client,
    name,
    count(distinct url) as pages,
    sum(freq) as freq,
    sum(sum(freq)) over (partition by client) as total,
    sum(freq) / sum(sum(freq)) over (partition by client) as pct
from
    (
        select client, url, prop.name, prop.freq
        from `httparchive.almanac.parsed_css`, unnest(getcalcproperties(css)) as prop
        where
            date = '2021-07-01'
            # Limit the size of the CSS to avoid OOM crashes.
            and length(css) < 0.1 * 1024 * 1024
    )
group by client, name
having pages >= 100
order by pct desc
