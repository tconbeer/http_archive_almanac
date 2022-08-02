# standardSQL
create temporary function getselectorparts(css string)
returns struct < class array < struct < name string,
value int64 >>,
id array < struct < name string,
value int64 >>,
attribute array < struct < name string,
value int64 >>,
pseudo_class array < struct < name string,
value int64 >>,
pseudo_element array < struct < name string,
value int64 >> >
language js
options(library = "gs://httparchive/lib/css-utils.js") as '''
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
    }).map(([name, value]) => ({name, value}));
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
  return {class: [{name: e, value: 0}]};
}
'''
;

# https://www.stevenmoseley.com/blog/tech/high-performance-sql-correlated-scalar-aggregate-reduction-queries
create temporary function encode(comparator string, data string) returns string as (
    concat(lpad(comparator, 11, '0'), data)
)
;
create temporary function decode(value string
) returns string as (substr(value, 12))
;

with
    selector_parts as (
        select client, page, url, getselectorparts(css) as parts
        from `httparchive.almanac.parsed_css`
        # Limit the size of the CSS to avoid OOM crashes.
        where date = '2020-08-01' and length(css) < 0.1 * 1024 * 1024
    )

select
    client,
    decode(max(encode(cast(class_freq as string), class_name))) as class_name,
    max(class_freq) as class_freq,
    decode(max(encode(cast(id_freq as string), id_name))) as id_name,
    max(id_freq) as id_freq,
    decode(
        max(encode(cast(attribute_freq as string), attribute_name))
    ) as attribute_name,
    max(attribute_freq) as attribute_freq,
    decode(
        max(encode(cast(pseudo_class_freq as string), pseudo_class_name))
    ) as pseudo_class_name,
    max(pseudo_class_freq) as pseudo_class_freq,
    decode(
        max(encode(cast(pseudo_element_freq as string), pseudo_element_name))
    ) as pseudo_element_name,
    max(pseudo_element_freq) as pseudo_element_freq
from
    (
        select
            client,
            class.name as class_name,
            sum(class.value) over (partition by client, class.name) as class_freq
        from selector_parts, unnest(parts.class) as class
    )
join
    (
        select
            client,
            id.name as id_name,
            sum(id.value) over (partition by client, id.name) as id_freq
        from selector_parts, unnest(parts.id) as id
    ) using (client)
join
    (
        select
            client,
            attribute.name as attribute_name,
            sum(attribute.value) over (
                partition by client, attribute.name
            ) as attribute_freq
        from selector_parts, unnest(parts.attribute) as attribute
    ) using (client)
join
    (
        select
            client,
            pseudo_class.name as pseudo_class_name,
            sum(pseudo_class.value) over (
                partition by client, pseudo_class.name
            ) as pseudo_class_freq
        from selector_parts, unnest(parts.pseudo_class) as pseudo_class
    ) using (client)
join
    (
        select
            client,
            pseudo_element.name as pseudo_element_name,
            sum(pseudo_element.value) over (
                partition by client, pseudo_element.name
            ) as pseudo_element_freq
        from selector_parts, unnest(parts.pseudo_element) as pseudo_element
    ) using (client)
group by client
