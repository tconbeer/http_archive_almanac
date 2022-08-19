# standardSQL
# 10_13: % of desktop pages that include a stylesheet with a breakpoint under 600px.
# See also 12_06
create temporary function hasbreakpoint(css string)
returns boolean language js as '''
function matchAll(re, str) {
  var results = [];
  while ((matches = re.exec(str)) !== null) {
    results.push(matches[1]);
  }
  return results;
}

try {
  var $ = JSON.parse(css);
  return $.stylesheet.rules.some(rule => {
    return rule.type == 'media' &&
        rule.media &&
        matchAll(/width:\\s*(\\d+)px/ig, rule.media).some(match => +match < 600);
  });
} catch (e) {
  false;
}
'''
;

select
    count(distinct page) as pages, round(count(distinct page) * 100 / total, 2) as pct
from
    (select page, css from `httparchive.almanac.parsed_css` where client = 'desktop'),
    (select count(0) as total from `httparchive.summary_pages.2019_07_01_desktop`)
where date = '2019-07-01' and hasbreakpoint(css)
group by total
