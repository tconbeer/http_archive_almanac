# standardSQL
create temporary function getspecificityinfo(css string)
returns struct < rulecount numeric,
selectorcount numeric,
distribution array < struct < specificity string,
specificity_cmp string,
freq int64 >> >
language js
options(library = "gs://httparchive/lib/css-utils.js")
as '''
try {
  function extractSpecificity(ast) {
    let ret = {
      selectorCount: 0,
      ruleCount: 0,
      specificityCount: {},
      maxSpecifity: [0, 0, 0]
    };

    let ss = [0, 0, 0];

    walkRules(ast, rule => {
      ret.ruleCount++;

      for (let selector of rule.selectors) {
        ret.selectorCount++;
        let s = parsel.specificity(selector);
        ss = ss.map((a, i) => a + s[i]);
        let max = Math.max(...s);

        incrementByKey(ret.specificityCount, max <= 5? s + "" : "higher");

        let base = Math.max(...ret.maxSpecifity, ...s);
        if (parsel.specificityToNumber(s, base) > parsel.specificityToNumber(ret.maxSpecifity, base)) {
          ret.maxSpecifity = s;
          ret.maxSpecifitySelector = selector;
        }
      }
    }, {type: "rule"});

    ret.selectorsPerRule = ret.selectorCount / ret.ruleCount;
    ret.avgSpecificity = ss.map(s => s / ret.selectorCount);

    return ret;
  }

  function toComparableString(specificity) {
    if (!specificity) {
      return null;
    }
    if (specificity.split(',').length !== 3) {
      return null;
    }

    // The highest unit of specificity is 9398, so we need 5 digits of padding.
    // Fun fact: the most specific selector in the dataset is 1065,9398,7851!
    return specificity.split(',').map(i => i.padStart(5, '0')).join('');
  }

  const ast = JSON.parse(css);
  let specificity = extractSpecificity(ast);
  let ruleCount = specificity.ruleCount;
  let selectorCount = specificity.selectorCount;
  let distribution = Object.entries(specificity.specificityCount).map(([specificity, freq]) => {
    return {
      specificity,
      freq,
      specificity_cmp: toComparableString(specificity)
    }
  });

  return {
    ruleCount,
    selectorCount,
    distribution
  };
} catch (e) {
  return null;
}
'''
;

select
    percentile,
    client,
    approx_quantiles(rule_count, 1000 ignore nulls)[
        offset(percentile * 10)
    ] as rule_count,
    approx_quantiles(selector_count, 1000 ignore nulls)[
        offset(percentile * 10)
    ] as selector_count,
    approx_quantiles(safe_divide(selector_count, rule_count), 1000 ignore nulls)[
        offset(percentile * 10)
    ] as selectors_per_rule
from
    (
        select
            client,
            sum(info.rulecount) as rule_count,
            sum(info.selectorcount) as selector_count
        from
            (
                select client, page, getspecificityinfo(css) as info
                from `httparchive.almanac.parsed_css`
                # Limit the size of the CSS to avoid OOM crashes. This loses ~20% of
                # stylesheets.
                where date = '2021-07-01' and length(css) < 0.1 * 1024 * 1024
            )
        group by client, page
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
