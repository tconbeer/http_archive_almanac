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
    client, pages, class.value as class, class.count as freq, class.count / pages as pct
from
    (
        select
            client,
            count(distinct page) as pages,
            approx_top_count(class, 100) as classes
        from
            (
                select distinct client, page, class
                from `httparchive.almanac.parsed_css`
                left join unnest(getselectorparts(css).class) as class
                where
                    date = '2020-08-01'
                    # Limit the size of the CSS to avoid OOM crashes.
                    and length(css) < 0.1 * 1024 * 1024
            )
        group by client
    ),
    unnest(classes) as class
where class.value is not null
order by pct desc
