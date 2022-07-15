# standardSQL
create temporary function getdirvalues(css string)
returns array < struct < element string,
value string,
freq int64 >> language js
options(library = "gs://httparchive/lib/css-utils.js") as '''
try {
  function compute(ast) {
    let ret = {
      html: {},
      body: {},
      other: {}
    };

    walkDeclarations(ast, ({value}, rule) => {
      if (rule.selectors) {
        for (let selector of rule.selectors) {
          let sast = parsel.parse(selector, {list: false});

          let node = sast.type === "complex"? sast.right : sast;
          let list = node.type === "compound"? node.list : [node];
          if (list.find(n => n.content === "html" || n.content === ":root")) {
            incrementByKey(ret.html, value);
          }
          else if (list.find(n => n.content === "body")) {
            incrementByKey(ret.body, value);
          }
          else {
            incrementByKey(ret.other, value);
          }
        }
      }
    }, {properties: "direction"});

    for (let type in ret) {
      ret[type].total = sumObject(ret[type]);
    }

    return ret;
  }
  var ast = JSON.parse(css);
  var dirs = compute(ast);
  return Object.entries(dirs).flatMap(([element, values]) => {
    return Object.entries(values).filter(([value]) => {
      return value != 'total';
    }).map(([value, freq]) => {
      return {element, value, freq};
    });
  });
} catch (e) {
  return [];
}
'''
;

select *
from
    (
        select
            client,
            element,
            value,
            sum(freq) as freq,
            sum(sum(freq)) over (partition by client, element) as total,
            sum(freq) / sum(sum(freq)) over (partition by client, element) as pct
        from
            (
                select client, dir.element, dir.value, dir.freq
                from `httparchive.almanac.parsed_css`, unnest(getdirvalues(css)) as dir
                # Limit the size of the CSS to avoid OOM crashes.
                where date = '2021-07-01' and length(css) < 0.1 * 1024 * 1024
            )
        group by client, element, value
    )
where pct >= 0.01
order by client, element, pct desc
