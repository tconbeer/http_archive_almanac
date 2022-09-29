# standardSQL
create temporary function getcustompropertylengths(payload string)
returns array < struct < depth int64,
freq int64 >> language js
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
      depths: {}
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
            incrementByKey(ret, "cycles_or_initial");
          }
          else {
            let depth = countDependencyLength(node, property);

            incrementByKey(ret.depths, depth);
          }
        }
      }
    });

    return ret;
  }
  var $ = JSON.parse(payload);
  var vars = JSON.parse($['_css-variables']);
  if (!vars || !vars.computed) return null;
  var custom_props = compute(vars);
  return Object.entries(custom_props.depths).map(([depth, freq]) => ({depth, freq}))
} catch (e) {
  return [];
}
'''
;

select
    client,
    depth,
    count(distinct url) as pages,
    sum(freq) as freq,
    sum(sum(freq)) over (partition by client) as total,
    sum(freq) / sum(sum(freq)) over (partition by client) as pct
from
    (
        select
            _table_suffix as client,
            url,
            custom_properties.depth,
            custom_properties.freq
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(getcustompropertylengths(payload)) as custom_properties
    )
group by client, depth
order by depth, client
