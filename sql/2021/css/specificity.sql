# standardSQL
create temporary function getspecificityinfo(css string)
returns
    struct<
        rulecount numeric,
        selectorcount numeric,
        distribution array<
            struct<specificity string, specificity_cmp string, freq int64>
        >
    >
language js
options (library = "gs://httparchive/lib/css-utils.js")
as
    '''
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
    return specificity.split(',').map(i => i.padStart(5, '0')).join('') + specificity;
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

# https://www.stevenmoseley.com/blog/tech/high-performance-sql-correlated-scalar-aggregate-reduction-queries
create temporary function extractspecificity(specificity_cmp string)
returns string
as (substr(specificity_cmp, 16))
;

select
    percentile,
    client,
    extractspecificity(
        approx_quantiles(max_specificity_cmp, 1000)[offset(percentile * 10)]
    ) as max_specificity,
    extractspecificity(
        approx_quantiles(median_specificity_cmp, 1000)[offset(percentile * 10)]
    ) as median_specificity
from
    (
        select
            client,
            max(specificity_cmp) as max_specificity_cmp,
            min(if(freq_cdf >= 0.5, specificity_cmp, null)) as median_specificity_cmp
        from
            (
                select
                    client,
                    page,
                    bin.specificity_cmp,
                    sum(bin.freq) over (
                        partition by client, page order by bin.specificity_cmp
                    )
                    / sum(bin.freq) over (partition by client, page) as freq_cdf
                from
                    (
                        select client, page, getspecificityinfo(css) as info
                        from `httparchive.almanac.parsed_css`
                        where
                            date = '2021-07-01'
                            # Limit the size of the CSS to avoid OOM crashes.
                            and length(css) < 0.1 * 1024 * 1024
                    ),
                    unnest(info.distribution) as bin
                where bin.specificity_cmp is not null
            )
        group by client, page
    ),
    unnest([10, 25, 50, 75, 90, 95, 99, 100]) as percentile
group by percentile, client
order by percentile, client
