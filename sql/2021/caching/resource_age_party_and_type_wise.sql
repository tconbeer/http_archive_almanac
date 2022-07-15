# standardSQL
# Age of resources party, type wise.
create temporary function totimestamp(date_string string)
returns int64 language js as '''
  try {
    var timestamp = Math.round(new Date(date_string).getTime() / 1000);
    return isNaN(timestamp) || timestamp < 0 ? null : timestamp;
  } catch (e) {
    return null;
  }
'''
;

select
    percentile,
    _table_suffix as client,
    if(
        net.host(url) in (
            select domain
            from `httparchive.almanac.third_parties`
            where date = '2021-07-01' and category != 'hosting'
        ),
        'third party',
        'first party'
    ) as party,
    type as resource_type,
    approx_quantiles(
        round(
            (starteddatetime - totimestamp(resp_last_modified)) / (60 * 60 * 24 * 7)
        ),
        1000 ignore nulls
    ) [offset (percentile * 10)
    ] as age_weeks
from
    `httparchive.summary_requests.2021_07_01_*`,
    unnest( [10, 25, 50, 75, 90]) as percentile
where trim(resp_last_modified) != ''
group by percentile, client, party, resource_type
order by percentile, client, party, resource_type
