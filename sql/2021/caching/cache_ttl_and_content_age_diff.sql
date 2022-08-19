# standardSQL
# Difference between Cache TTL and the contents age
create temporary function totimestamp(date_string string)
returns int64 language js as '''
  try {
    var timestamp = Math.round(new Date(date_string).getTime() / 1000);
    return isNaN(timestamp) || timestamp < 0 ? -1 : timestamp;
  } catch (e) {
    return null;
  }
'''
;

select
    client,
    percentile,
    approx_quantiles(diff_in_days, 1000 ignore nulls)[
        offset(percentile * 10)
    ] as diff_in_days
from
    (
        select
            _table_suffix as client,
            round(
                (expage - (starteddatetime - totimestamp(resp_last_modified)))
                / (60 * 60 * 24),
                2
            ) as diff_in_days
        from `httparchive.summary_requests.2021_07_01_*`
        where resp_last_modified != '' and expage > 0
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by client, percentile
order by client, percentile
