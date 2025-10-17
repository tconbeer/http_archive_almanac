# standardSQL
# 02_34: Distribution of fonts declared per page
create temporary function countfonts(css string)
returns int64
language js
as '''
try {
  var $ = JSON.parse(css);
  return $.stylesheet.rules.filter(rule => rule.type == 'font-face').length;
} catch (e) {
  return 0;
}
'''
;

select
    client,
    approx_quantiles(font_rules, 1000)[offset(100)] as p10,
    approx_quantiles(font_rules, 1000)[offset(250)] as p25,
    approx_quantiles(font_rules, 1000)[offset(500)] as p50,
    approx_quantiles(font_rules, 1000)[offset(750)] as p75,
    approx_quantiles(font_rules, 1000)[offset(900)] as p90
from
    (
        select client, sum(countfonts(css)) as font_rules
        from `httparchive.almanac.parsed_css`
        where date = '2019-07-01'
        group by client, page
    )
group by client
