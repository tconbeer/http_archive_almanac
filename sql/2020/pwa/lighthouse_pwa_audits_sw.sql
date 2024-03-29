# standardSQL
# Get summary of all lighthouse scores for a category for PWA pages
# Note scores, weightings, groups and descriptions may be off in mixed months when new
# versions of Lighthouse roles out
create temporary function getaudits(report string, category string)
returns
    array<
        struct<
            id string,
            weight int64,
            audit_group string,
            title string,
            description string,
            score int64
        >
    >
language js
as '''
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
'''
;

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
    `httparchive.lighthouse.2020_08_01_mobile` l,
    `httparchive.almanac.service_workers`,
    unnest(getaudits(report, 'pwa')) as audits
where
    date = '2020-08-01'
    and client = 'mobile'
    and page = l.url
    and length(report) < 20000000  # necessary to avoid out of memory issues. Excludes 16 very large results
group by audits.id
order by median_weight desc, id
