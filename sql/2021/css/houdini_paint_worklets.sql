# standardSQL
create temporary function getpaintworklets(css string)
returns array < struct < name string,
freq int64 >> language js
options(library = "gs://httparchive/lib/css-utils.js") as '''
try {
  var ast = JSON.parse(css);
  var ret = {};
  walkDeclarations(ast, ({property, value}) => {
    for (let paint of extractFunctionCalls(value, {names: "paint"})) {
      let name = paint.args.match(/^[-\\w+]+/)[0];

      if (name) {
        incrementByKey(ret, name);
      }
    }
  }, {
    properties: /^--|-image$|^background$|^content$/,
    values: /\\bpaint\\(/
  });

  return Object.entries(ret).map(([name, freq]) => ({name, freq}))
} catch (e) {
  return [];
}
'''
;

select
    client,
    worklet,
    count(distinct url) as pages,
    sum(freq) as freq,
    sum(sum(freq)) over (partition by client) as total,
    sum(freq) / sum(sum(freq)) over (partition by client) as pct
from
    (
        select client, url, paint.name as worklet, paint.freq
        from `httparchive.almanac.parsed_css`, unnest(getpaintworklets(css)) as paint
        where date = '2021-07-01'
    )
group by client, worklet
order by pct desc
