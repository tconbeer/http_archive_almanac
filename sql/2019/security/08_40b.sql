# standardSQL
# 08_40b: Most frequent vulnerable libraries
CREATE TEMPORARY FUNCTION getVulnerabilities(report STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
  var $ = JSON.parse(report);
  return $.audits['no-vulnerable-libraries'].details.items.map(i => i.detectedLib.text.split('@')[0]);
} catch(e) {
  return [];
}
''';

select
    lib,
    count(0) as freq,
    sum(count(0)) over () as total,
    round(count(0) * 100 / sum(count(0)) over (), 2) as pct
from
    `httparchive.lighthouse.2019_07_01_mobile`,
    unnest(getvulnerabilities(report)) as lib
group by lib
order by freq desc
