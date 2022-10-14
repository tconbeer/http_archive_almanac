# standardSQL
CREATE TEMPORARY FUNCTION getSelectorParts(css STRING)
RETURNS STRUCT<
  class ARRAY<STRING>,
  id ARRAY<STRING>,
  attribute ARRAY<STRING>,
  pseudo_class ARRAY<STRING>,
  pseudo_element ARRAY<STRING>
>
LANGUAGE js
OPTIONS (library = "gs://httparchive/lib/css-utils.js")
AS '''
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
''';

select
    client,
    pages,
    pseudo_element.value as pseudo_element,
    pseudo_element.count as freq,
    pseudo_element.count / pages as pct
from
    (
        select
            client,
            count(distinct page) as pages,
            approx_top_count(pseudo_element, 100) as pseudo_elements
        from
            (
                select distinct client, page, pseudo_element
                from `httparchive.almanac.parsed_css`
                left join unnest(getselectorparts(css).pseudo_element) as pseudo_element
                # Limit the size of the CSS to avoid OOM crashes.
                where date = '2020-08-01' and length(css) < 0.1 * 1024 * 1024
            )
        group by client
    ),
    unnest(pseudo_elements) as pseudo_element
where pseudo_element.value is not null
order by pct desc
