# standardSQL
create temporary function getselectorparts(css string)
returns
    struct<
        class array<string>,
        id array<string>,
        attribute array<string>,
        pseudo_class array<string>,
        pseudo_element array<string>
    >
language js
options (library = "gs://httparchive/lib/css-utils.js")
as '''
try {
  function compute(ast) {
    let ret = {
      class: {},
      id: {},
      attribute: {},
      "pseudo-class": {},
      "pseudo-element": {}
    };

    walkSelectors(ast, selector => {
      let sast = parsel.parse(selector, {list: false});

      parsel.walk(sast, node => {
        if (node.type in ret) {
          incrementByKey(ret[node.type], node.name);
        }
      }, {subtree: true});
    });

    for (let type in ret) {
      ret[type] = sortObject(ret[type]);
    }

    return ret;
  }

  function unzip(obj) {
    return Object.entries(obj).filter(([name, value]) => {
      return !isNaN(value);
    }).map(([name, value]) => name);
  }

  const ast = JSON.parse(css);
  let parts = compute(ast);
  return {
    class: unzip(parts.class),
    id: unzip(parts.id),
    attribute: unzip(parts.attribute),
    pseudo_class: unzip(parts['pseudo-class']),
    pseudo_element: unzip(parts['pseudo-element'])
  }
} catch (e) {
  return null;
}
'''
;

select
    client,
    countif(num_focus_visible > 0) as has_focus_visible,
    count(0) as total,
    countif(num_focus_visible > 0) / count(0) as pct_pages_focus_visible
from
    (
        select
            client, page, countif(pseudo_class = 'focus-visible') as num_focus_visible
        from `httparchive.almanac.parsed_css`
        left join unnest(getselectorparts(css).pseudo_class) as pseudo_class
        where date = '2021-07-01'
        group by client, page
    )
group by client
