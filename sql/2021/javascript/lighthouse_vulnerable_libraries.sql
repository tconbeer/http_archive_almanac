# standardSQL
# Most frequent vulnerable libraries
create temporary function getvulnerabilities(audit string)
returns array
< string
> language js as '''
try {
  var $ = JSON.parse(audit);
  return $.details.items.map(i => i.detectedLib.text.split('@')[0]);
} catch(e) {
  return [];
}
'''
;

select lib, count(0) as freq, total, count(0) / total as pct
from
    `httparchive.lighthouse.2021_07_01_mobile`,
    unnest(
        getvulnerabilities(json_extract(report, "$.audits['no-vulnerable-libraries']"))
    ) as lib,
    (
        select count(distinct url) as total
        from `httparchive.lighthouse.2021_07_01_mobile`
    )
group by lib, total
order by freq desc
