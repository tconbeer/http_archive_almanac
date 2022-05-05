# standardSQL
create temporary function getanimatedcustomproperties(css string)
returns array < string > language js
options(library = "gs://httparchive/lib/css-utils.js")
as '''
try {
  const ast = JSON.parse(css);
  let ret = new Set();

  walkRules(ast, rule => {
    walkDeclarations(rule.keyframes, ({property, value}) => {
      ret.add(property);
    }, {
      properties: /^--/
    });
  }, {
    type: "keyframes"
  });

  return [...ret];
} catch (e) {
  return [];
}
'''
;

create temporary function getcustompropertieswithcomputedstyle(payload string) returns
array
< string
> language js
as '''
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

select client, count(distinct page) as pages
from
    (
        select client, page, prop
        from
            `httparchive.almanac.parsed_css`,
            unnest(getanimatedcustomproperties(css)) as prop
        where date = '2021-07-01'
    )
join
    (
        select _table_suffix as client, url as page, prop
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(getcustompropertieswithcomputedstyle(payload)) as prop
    )
    using
    (client, page, prop)
group by client
