# standardSQL
# Age of resources party, type wise in groups.
CREATE TEMPORARY FUNCTION toTimestamp(date_string STRING)
RETURNS INT64 LANGUAGE js AS '''
  try {
    var timestamp = Math.round(new Date(date_string).getTime() / 1000);
    return isNaN(timestamp) || timestamp < 0 ? null : timestamp;
  } catch (e) {
    return null;
  }
''';

select
    client,
    party,
    resource_type,
    count(0) as requests_total,
    countif(age_weeks is not null) as requests_with_age,
    countif(age_weeks < 0) as age_neg,
    countif(age_weeks = 0) as age_0wk,
    countif(age_weeks >= 1 and age_weeks <= 7) as age_1_to_7wk,
    countif(age_weeks >= 8 and age_weeks <= 52) as age_8_to_52wk,
    countif(age_weeks >= 53 and age_weeks <= 104) as age_gt_1y,
    countif(age_weeks >= 105) as age_gt_2y,
    safe_divide(countif(age_weeks < 0), countif(age_weeks is not null)) as age_neg_pct,
    safe_divide(countif(age_weeks = 0), countif(age_weeks is not null)) as age_0wk_pct,
    safe_divide(
        countif(age_weeks >= 1 and age_weeks <= 7), countif(age_weeks is not null)
    ) as age_1_to_7wk_pct,
    safe_divide(
        countif(age_weeks >= 8 and age_weeks <= 52), countif(age_weeks is not null)
    ) as age_8_to_52wk_pct,
    safe_divide(
        countif(age_weeks >= 53 and age_weeks <= 104), countif(age_weeks is not null)
    ) as age_gt_1y_pct,
    safe_divide(
        countif(age_weeks >= 105), countif(age_weeks is not null)
    ) as age_gt_2y_pct
from
    (
        select
            _table_suffix as client,
            if(
                net.host(url) in (
                    select domain
                    from `httparchive.almanac.third_parties`
                    where date = '2020-08-01' and category != 'hosting'
                ),
                'third party',
                'first party'
            ) as party,
            type as resource_type,
            round(
                (starteddatetime - totimestamp(resp_last_modified)) / (60 * 60 * 24 * 7)
            ) as age_weeks
        from `httparchive.summary_requests.2020_08_01_*`
        where trim(resp_last_modified) != ''
    )
group by client, party, resource_type
order by client, party, resource_type
