# standardSQL
create temporary function getcustompropertyproperties(css string)
returns array < string > language js
options(library = "gs://httparchive/lib/css-utils.js")
as '''
try {
  function compute(ast) {
    let ret = {
      properties: {},
      functions: {},
      supports: {},
      "pseudo-classes": {},
      fallback: {
        none: 0,
        literal: 0,
        var: 0
      },
      initial: 0
    };

    walkRules(ast, rule => {
      for (let match of rule.supports.matchAll(/\\(--(?<name>[\\w-]+)\\s*:/g)) {
        incrementByKey(ret.supports, match.groups.name);
      }
    }, {type: "supports"});

    let parsedSelectors = {};

    walkDeclarations(ast, ({property, value}, rule) => {
      if (matches(value, /\\bvar\\(\\s*--/)) {
        if (!property.startsWith("--")) {
          incrementByKey(ret.properties, property);
        }

        for (let call of extractFunctionCalls(value)) {
          if (call.name === "var") {
            let fallback = call.args.split(",").slice(1).join(",");

            if (matches(fallback, /\\bvar\\(\\s*--/)) {
              ret.fallback.var++;
            }
            else if (fallback) {
              ret.fallback.literal++;
            }
            else {
              ret.fallback.none++;
            }
          }
          else if (call.args.includes("var(--")) {
            incrementByKey(ret.functions, call.name);
          }
        }
      }

      if (property.startsWith("--")) {
        if (value === "initial") {
          ret.initial++;
        }

        if (rule.selectors) {
          for (let selector of rule.selectors) {
            let sast = parsedSelectors[selector] = parsedSelectors[selector] || parsel.parse(selector);
            parsel.walk(sast, node => {
              if (node.type === "pseudo-class") {
                incrementByKey(ret["pseudo-classes"], node.name);
              }
            })
          }
        }

      }
    });

    for (let type in ret) {
      ret[type] = sortObject(ret[type]);
    }

    return ret;
  }

  const ast = JSON.parse(css);
  let custom_property = compute(ast);
  return Object.keys(custom_property.properties);
} catch (e) {
  return [];
}
'''
;

select
    client,
    property,
    count(distinct page) as pages,
    total,
    count(distinct page) / total as pct
from
    (
        select distinct client, page, lower(property) as property
        from `httparchive.almanac.parsed_css`
        left join unnest(getcustompropertyproperties(css)) as property
        where date = '2021-07-01' and property is not null
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2021_07_01_*`
        group by client
    ) using (client)
group by client, total, property
having pct >= 0.01
order by pct desc
