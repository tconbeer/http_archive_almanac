# standardSQL
create temporary function getcustompropertieswithcomputedstyle(payload string) returns
array
< string
> language js as '''
try {
  var $ = JSON.parse(payload);
  var vars = JSON.parse($['_css-variables']);

  function walkElements(node, callback) {
    if (Array.isArray(node)) {
      for (let n of node) {
        walkElements(n, callback);
      }
    }
    else {
      callback(node);

      if (node.children) {
        walkElements(node.children, callback);
      }
    }
  }

  let ret = new Set();

  walkElements(vars.computed, node => {
    if (node.declarations) {
      for (let property in node.declarations) {
        let o = node.declarations[property];

        if (property.startsWith("--") && o.type) {
          ret.add(property);
        }
      }
    }
  });

  return [...ret];
} catch (e) {
  return [];
}
'''
;

select distinct
    _table_suffix as client,
    prop,
    count(distinct url) over (partition by _table_suffix, prop) as pages,
    count(distinct url) over (partition by _table_suffix) as total,
    count(distinct url) over (partition by _table_suffix, prop)
    / count(distinct url) over (partition by _table_suffix) as pct
from
    `httparchive.pages.2021_07_01_*`,
    unnest(getcustompropertieswithcomputedstyle(payload)) as prop
order by pct desc
