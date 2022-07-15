# standardSQL
create temporary function getcustompropertymaxcycles(payload string)
returns int64
language js
options(library = "gs://httparchive/lib/css-utils.js")
as '''
try {
  function compute(vars) {
    function walkElements(node, callback, parent) {
      if (Array.isArray(node)) {
        for (let n of node) {
          walkElements(n, callback, parent);
        }
      }
      else {
        callback(node, parent);

        if (node.children) {
          walkElements(node.children, callback, node);
        }
      }
    }

    let ret = {
      max_length: 0,
      cycles_or_initial: 0
    };

    function countDependencyLength(node, property) {
      if (!node) {
        return 0;
      }

      let declarations = node.declarations;

      if (!declarations || !(property in declarations)) {
        return countDependencyLength(node.parent, property);
      }

      let o = declarations[property];

      if (!o.references || o.references.length === 0) {
        return 0;
      }

      let lengths = o.references.map(p => countDependencyLength(node, p));

      return 1 + Math.max(...lengths);
    }

    walkElements(vars.computed, (node, parent) => {
      if (parent && !node.parent) {
        node.parent = parent;
      }

      if (node.declarations) {
        for (let property in node.declarations) {

          let o = node.declarations[property];
          if (o.computed && o.computed.trim() !== o.value.trim() && (o.computed === "initial" || o.computed === "null")) {
            // Cycle or missing ref
            ret.cycles_or_initial++;
          }
          else {
            let depth = countDependencyLength(node, property);

            if (depth > ret.max_length) {
              ret.max_length = depth;
            }

            incrementByKey(ret, depth);
          }
        }
      }
    });

    return ret;
  }
  var $ = JSON.parse(payload);
  var vars = JSON.parse($['_css-variables']);
  var custom_props = compute(vars);
  if (!('max_length' in custom_props)) return null;
  return custom_props.max_length;
} catch (e) {
  return null;
}
'''
;

select
    percentile,
    client,
    approx_quantiles(
        max_cycles, 1000 ignore nulls) [offset (percentile * 10)
    ] as max_cycles_per_page
from
    (
        select
            _table_suffix as client,
            url,
            max(getcustompropertymaxcycles(payload)) as max_cycles
        from `httparchive.pages.2021_07_01_*`
        group by client, url
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
