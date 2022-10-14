# standardSQL
# Get summary of all lighthouse scores for a category
# Note scores, weightings, groups and descriptions may be off in mixed months when new
# versions of Lighthouse roles out
CREATE TEMPORARY FUNCTION getAudits(report STRING, category STRING)
RETURNS ARRAY<STRUCT<id STRING, weight INT64, audit_group STRING, title STRING, description STRING, score INT64>> LANGUAGE js AS '''
var $ = JSON.parse(report);
var auditrefs = $.categories[category].auditRefs;
var audits = $.audits;
$ = null;
var results = [];
for (auditref of auditrefs) {
  results.push({
    id: auditref.id,
    weight: auditref.weight,
    audit_group: auditref.group,
    description: audits[auditref.id].description,
    score: audits[auditref.id].score
  });
}
return results;
''';

select
    audits.id as id,
    countif(audits.score > 0) as num_pages,
    count(0) as total,
    countif(audits.score is not null) as total_applicable,
    safe_divide(countif(audits.score > 0), countif(audits.score is not null)) as pct,
    approx_quantiles(audits.weight, 100)[offset(50)] as median_weight,
    max(audits.audit_group) as audit_group,
    max(audits.description) as description
from
    `httparchive.lighthouse.2021_07_01_mobile`,
    unnest(getaudits(report, 'accessibility')) as audits
# necessary to avoid out of memory issues. Excludes very large results
where length(report) < 20000000
group by audits.id
order by median_weight desc, id
