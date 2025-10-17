# standardSQL
create temporary function getcustompropertyroots(payload string)
returns array<struct<name string, freq int64>>
language js
options (library = "gs://httparchive/lib/css-utils.js")
as '''
try {
  function compute(vars) {
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

    let ret = {
      root: 0,
      body: 0,
      descendants: 0
    };

    walkElements(vars.computed, node => {
      if (node.declarations) {
        for (let property in node.declarations) {
          let value;
          let o = node.declarations[property];

          if (property.startsWith("--")) {
            if (/^HTML\\b/.test(node.element)) {
              ret.root++;
            }
            else if (/^BODY\\b/.test(node.element)) {
              ret.body++;
            }
            else {
              ret.descendants++;
            }
          }
        }
      }
    });

    return ret;
  }
  var $ = JSON.parse(payload);
  var vars = JSON.parse($['_css-variables']);
  var custom_properties = compute(vars);
  return Object.entries(custom_properties).map(([name, freq]) => ({name, freq}))
} catch (e) {
  return null;
}
'''
;

select
    client,
    name as root,
    sum(freq) as freq,
    sum(sum(freq)) over (partition by client) as total,
    sum(freq) / sum(sum(freq)) over (partition by client) as pct,
    count(distinct if(freq > 0, page, null)) as pages,
    total_pages,
    count(distinct if(freq > 0, page, null)) / total_pages as pct_pages
from
    (
        select _table_suffix as client, url as page, root.name, root.freq
        from
            `httparchive.pages.2020_08_01_*`,
            unnest(getcustompropertyroots(payload)) as root
    )
join
    (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
    ) using (client)
group by client, root, total_pages
order by pct desc
