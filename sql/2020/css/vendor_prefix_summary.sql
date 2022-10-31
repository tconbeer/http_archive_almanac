# standardSQL
create temporary function getprefixstats(css string)
returns array<string>
language js
options (library = "gs://httparchive/lib/css-utils.js")
as
    '''
try {
  function compute() {
    let ret = {
      total: {},
      pseudo_classes: {},
      pseudo_elements: {},
      properties: {},
      functions: {},
      keywords: {},
      media: {}
    };

    ret.total = Object.fromEntries(Object.keys(ret).map(k => [k, 0]));

    walkRules(ast, rule => {
      // Prefixed pseudos
      if (rule.selectors) {
        let pseudos = rule.selectors.flatMap(r => r.match(/::?-[a-z]+-[\\w-]+/g) || []);

        for (let pseudo of pseudos) {
          let type = "pseudo_" + (pseudo.indexOf("::") === 0? "elements" : "classes");
          incrementByKey(ret[type], pseudo);
          ret.total[type]++;
        }
      }

      if (rule.declarations) {
        walkDeclarations(rule, ({property, value}) => {
          if (value.length > 1000) {
            return;
          }

          // Prefixed properties
          if (/^-[a-z]+-.+/.test(property)) {
            incrementByKey(ret.properties, property);
            ret.total.properties++;
          }

          // -prefix-function()
          for (let call of extractFunctionCalls(value, {names: /^-[a-z]+-.+/})) {
            incrementByKey(ret.functions, call.name);
            ret.total.functions++;
          }

          // Prefixed keywords
          if (!matches(property, /(^|-)(transition(-property)?|animation(-name)?)$/)) {
            for (let k of value.matchAll(/(?<![-a-z])-[a-z]+-[a-z-]+(?=$|\\s|,|\\/)/g)) {
              incrementByKey(ret.keywords, k);
              ret.total.keywords++;
            }
          }
        });
      }

      // Prefixed media features
      if (rule.media) {
        let features = rule.media
                  .replace(/\\s+/g, "")
                  .match(/\\(-[a-z]+-[\\w-]+(?=[:\\)])/g);

        if (features) {
          features = features.map(s => s.slice(1));

          for (let feature of features) {
            incrementByKey(ret.media, feature);
            ret.total.media++;
          }
        }
      }
    });

    ret.total.total = sumObject(ret.total);

    for (let type in ret) {
      ret[type] = sortObject(ret[type]);
    }

    return ret;
  }


  let ast = JSON.parse(css);
  let stats = compute(ast).total;
  return Object.entries(stats).flatMap(([prop, freq]) => {
    return Array(freq).fill(prop);
  });
}
catch (e) {
  return [];
}
'''
;

select *
from
    (
        select
            client,
            prop,
            count(distinct page) as pages,
            count(0) as freq,
            sum(count(if(prop = 'total', null, 0))) over (partition by client) as total,
            count(if(prop = 'total', null, 0))
            / sum(count(if(prop = 'total', null, 0))) over (partition by client) as pct
        from `httparchive.almanac.parsed_css`, unnest(getprefixstats(css)) as prop
        where date = '2020-08-01'
        group by client, prop
    )
where pages >= 1000
order by pct desc
