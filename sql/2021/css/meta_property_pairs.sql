# standardSQL
create temporary function getpropertypairs(css string)
returns array < struct < pair string,
freq int64 >> language js
options(library = "gs://httparchive/lib/css-utils.js")
as '''
try {
  function compute(ast) {
    let usedTogether = {};

    walkRules(ast.stylesheet.rules, rule => {
      let props = new Set();

      if (!rule.declarations) {
        return;
      }

      let ruleProps = rule.declarations
        // Ignore custom properties and prefixed ones. CP because they don't generalize
        // and prefixed ones because they will trivially correlate with each other and the non-prefixed version
        .filter(d => !d.property.startsWith("-"))
        .map(d => d.property);

      for (let prop of ruleProps) {
        props.add(prop);
      }

      for (let prop of props) {
        usedTogether[prop] = usedTogether[prop] || {};

        for (let prop2 of props) {
          if (prop === prop2) {
            continue;
          }

          usedTogether[prop][prop2] = usedTogether[prop][prop2] || 0;
          usedTogether[prop][prop2]++;
        }
      }
    }, {
      // rules: r => Boolean(r.declarations),
      not: {
        type: "font-face"
      }
    });

    let ret = {};

    // Now sort by usage count
    for (let prop in usedTogether) {
      let obj = usedTogether[prop];

      // Remove properties that are only used together once
      for (let p in obj) {
        if (obj[p] === 1) {
          delete obj[p];
        }
        else {
          let key = [prop, p].sort();
          ret[key] = ret[key] || 0;
          ret[key] += obj[p];
        }
      }

      // let sortedEntries = Object.entries(obj).sort((a, b) => b[1] - a[1]);
      //
      // if (sortedEntries.length > 0) {
      //  usedTogether[prop] = Object.fromEntries(sortedEntries);
      // }
      // else {
      //  delete usedTogether[prop];
      // }
    }

    return sortObject(ret);
  }

  var ast = JSON.parse(css);
  var properties = compute(ast);
  return Object.entries(properties).map(([pair, freq]) => {
    return {pair, freq};
  });
} catch (e) {
  return [];
}
'''
;

select
    client,
    pair,
    count(distinct page) as pages,
    sum(freq) as freq,
    sum(sum(freq)) over (partition by client) as total,
    sum(freq) / sum(sum(freq)) over (partition by client) as pct
from
    (
        select client, page, property.pair, property.freq
        from `httparchive.almanac.parsed_css`, unnest(getpropertypairs(css)) as property
        # Limit the size of the CSS to avoid OOM crashes.
        where date = '2021-07-01' and length(css) < 0.1 * 1024 * 1024
    )
group by client, pair
order by pct desc
limit 500
