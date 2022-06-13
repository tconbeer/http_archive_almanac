# standardSQL
create temporary function getspecificityhacks(css string)
returns struct < bem numeric,
attribute_id numeric,
duplicate_classes numeric,
root_descendant numeric,
html_descendant numeric,
not_id_descendant numeric > language js
options(library = "gs://httparchive/lib/css-utils.js")
as '''
try {

function compute() {

let ret = {
  bem: 0,
  attribute_id: 0,
  duplicate_classes: 0,
  root_descendant: 0,
  html_descendant: 0,
  not_id_descendant: 0,
};

const bem = /^(?=.+--|.+__)[a-z0-9-]+(__[\\w-]+)?(--[\\w-]+)?$/i;

walkSelectors(ast, selector => {
  let sast = parsel.parse(selector, {list: false, recursive: false});

  parsel.walk(sast, (node, parent) => {
    if (node.type === "attribute" && node.name === "id" && node.operator === "=") {
      ret.attribute_id++;
    }
    else if (node.type === "compound") {
      // Look for duplicate classes
      let classes = new Set();

      for (let s of node.list) {
        if (s.type === "class") {
          if (classes.has(s.name)) {
            // Found a duplicate class
            ret.duplicate_classes++;
            break;
          }

          classes.add(s.name);
        }
      }
    }
    else if (!parent && node.type === "complex") {
      let first = node;
      // Find the firstmost compound
      while ((first = first.left) && first.type === "complex");

      if (first.combinator === " ") {
        first = first.left;
      }

      if (first.type === "pseudo-class" && first.name === "root") {
        ret.root_descendant++;
      }
      else if (first.type === "type" && first.name === "html") {
        ret.html_descendant++;
      }
      else if (first.type === "pseudo-class" && first.name === "not" && first.argument.startsWith("#")) {
        ret.not_id_descendant++;
      }
    }
    else if (node.type === "class" && (!parent || parent.type === "complex" && parent.combinator === " ")) {
      if (bem.test(node.name)) {
        ret.bem++;
      }
    }
  }, {subtree: true});
});

return ret;

}

  const ast = JSON.parse(css);
  return compute(ast);
} catch (e) {
  return null;
}
'''
;

select
    percentile,
    client,
    count(0) as total,
    countif(bem > 0) as bem_pages,
    countif(bem > 0) / count(0) as bem_pages_pct,
    approx_quantiles(bem, 1000 ignore nulls) [offset (percentile * 10)] as bem_per_page,
    countif(attribute_id > 0) as attribute_id_pages,
    countif(attribute_id > 0) / count(0) as attribute_id_pages_pct,
    approx_quantiles(attribute_id, 1000 ignore nulls) [
        offset (percentile * 10)
    ] as attribute_id_per_page,
    countif(duplicate_classes > 0) as duplicate_classes_pages,
    countif(duplicate_classes > 0) / count(0) as duplicate_classes_pages_pct,
    approx_quantiles(duplicate_classes, 1000 ignore nulls) [
        offset (percentile * 10)
    ] as duplicate_classes_per_page,
    countif(root_descendant > 0) as root_descendant_pages,
    countif(root_descendant > 0) / count(0) as root_descendant_pages_pct,
    approx_quantiles(root_descendant, 1000 ignore nulls) [
        offset (percentile * 10)
    ] as root_descendant_per_page,
    countif(html_descendant > 0) as html_descendant_pages,
    countif(html_descendant > 0) / count(0) as html_descendant_pages_pct,
    approx_quantiles(html_descendant, 1000 ignore nulls) [
        offset (percentile * 10)
    ] as html_descendant_per_page,
    countif(not_id_descendant > 0) as not_id_descendant_pages,
    countif(not_id_descendant > 0) / count(0) as not_id_descendant_pages_pct,
    approx_quantiles(not_id_descendant, 1000 ignore nulls) [
        offset (percentile * 10)
    ] as not_id_descendant_per_page
from
    (
        select
            client,
            sum(hack.bem) as bem,
            sum(hack.attribute_id) as attribute_id,
            sum(hack.duplicate_classes) as duplicate_classes,
            sum(hack.root_descendant) as root_descendant,
            sum(hack.html_descendant) as html_descendant,
            sum(hack.not_id_descendant) as not_id_descendant
        from
            (
                select client, page, getspecificityhacks(css) as hack
                from `httparchive.almanac.parsed_css`
                # Limit the size of the CSS to avoid OOM crashes.
                where date = '2021-07-01' and length(css) < 0.1 * 1024 * 1024
            )
        group by client, page
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
