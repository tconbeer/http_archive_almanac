# standardSQL
# Vulnerabilities per page by severity
create temporary function getvulnerabilities(audit string)
returns array < struct < severity string,
freq int64
>> language js
as '''
try {
  var $ = JSON.parse(audit);
  return $.details.items.map(({highestSeverity, vulnCount}) => {
    return {
      severity: highestSeverity,
      freq: vulnCount
    };
  });
} catch(e) {
  return [];
}
'''
;

select
    severity,
    count(distinct page) as pages,
    approx_quantiles(freq, 1000) [offset (500)] as median_vulnerability_count_per_page
from
    (
        select url as page, vulnerability.severity, sum(vulnerability.freq) as freq
        from `httparchive.lighthouse.2020_08_01_mobile`
        left join
            unnest(
                getvulnerabilities(
                    json_extract(report, "$.audits['no-vulnerable-libraries']")
                )
            ) as vulnerability
        group by page, severity
    )
group by severity
order by pages desc
