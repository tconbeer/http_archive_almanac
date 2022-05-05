# standardSQL
# 02_43: % of sites that use [id="foo"] selectors
create temporary function getattributeselectortype(css string)
returns struct < `=` boolean,
`*=` boolean,
`^=` boolean,
`$=` boolean,
`~=` boolean
>
language js
as '''
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    var selectors = rule.selectors || rule.selector && [rule.selector];
    if (!selectors) {
      return values;
    }

    selectors.forEach(selector => {
      var match = selector.match(/\\[id([*^$~]?=)/);
      if (match) {
        var operator = match[1];
        values[operator] = true;
      }
    });
    return values;
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, {});
} catch (e) {
  return {};
}
'''
;

select
    client,
    countif(equals > 0) as freq_equals,
    countif(star_equals > 0) as freq_star_equals,
    countif(caret_equals > 0) as freq_caret_equals,
    countif(dollar_equals > 0) as freq_dollar_equals,
    countif(tilde_equals > 0) as freq_tilde_equals,
    total,
    round(countif(equals > 0) * 100 / total, 2) as pct_equals,
    round(countif(star_equals > 0) * 100 / total, 2) as pct_star_equals,
    round(countif(caret_equals > 0) * 100 / total, 2) as pct_caret_equals,
    round(countif(dollar_equals > 0) * 100 / total, 2) as pct_dollar_equals,
    round(countif(tilde_equals > 0) * 100 / total, 2) as pct_tilde_equals
from
    (
        select
            client,
            countif(type.`=`) as equals,  -- noqa: L057
            countif(type.`*=`) as star_equals,  -- noqa: L057
            countif(type.`^=`) as caret_equals,  -- noqa: L057
            countif(type.`$=`) as dollar_equals,  -- noqa: L057
            countif(type.`~=`) as tilde_equals  -- noqa: L057
        from
            (
                select client, page, getattributeselectortype(css) as type
                from `httparchive.almanac.parsed_css`
                where date = '2019-07-01'
            )
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by client
    )
    using
    (client)
group by client, total
