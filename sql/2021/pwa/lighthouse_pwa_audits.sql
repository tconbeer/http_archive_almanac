# standardSQL
# Get summary of all lighthouse PWA audits, for both PWA pages and all pages
# Note scores, weightings, groups and descriptions may be off in mixed months when new
# versions of Lighthouse roles out
create temporary function getaudits(auditrefs string, audits string)
returns array < struct < id string,
weight int64,
audit_group string,
title string,
description string,
score int64
>> language js as '''
var auditrefs = JSON.parse(auditRefs);
var audits = JSON.parse(audits);
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
    'PWA Sites' as type,
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
    unnest(
        getaudits(
            json_extract(report, '$.categories.pwa.auditRefs'),
            json_extract(report, '$.audits')
        )
    ) as audits
join
    (
        select url
        from `httparchive.pages.2021_07_01_mobile`
        where
            json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
            and json_extract(payload, '$._pwa.manifests') != '[]'
    ) using (url)
group by audits.id
union all
select
    'ALL Sites' as type,
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
    unnest(
        getaudits(
            json_extract(report, '$.categories.pwa.auditRefs'),
            json_extract(report, '$.audits')
        )
    ) as audits
group by audits.id
order by type desc, median_weight desc, id
