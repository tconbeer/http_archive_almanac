# standardSQL
# 10_01: structured data rich results eligibility
# note: the RegExp options based on:
# https://developers.google.com/search/docs/guides/search-gallery
# note: homepage only data
# note: also see 10.05
create temporary function haseligibletype(payload string)
returns boolean language js
as '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    var found = almanac['10.5'].findIndex(type => {
        if(type.match(/(Breadcrumb|SearchAction|Offer|AggregateRating|Event|Review|Rating|SoftwareApplication|ContactPoint|NewsArticle|Book|Recipe|Course|EmployerAggregateRating|ClaimReview|Question|HowTo|JobPosting|LocalBusiness|Organization|Product|SpeakableSpecification|VideoObject)/i)) {
            return true;
        }
    });
    return found >= 0 ? true : false;
  } catch (e) {
    return false;
  }
'''
;

select
    client,
    countif(has_eligible_type) as freq,
    count(0) as total,
    round(countif(has_eligible_type) * 100 / sum(count(0)) over (), 2) as pct
from
    (
        select _table_suffix as client, haseligibletype(payload) as has_eligible_type
        from `httparchive.pages.2019_07_01_*`
    )
group by client
