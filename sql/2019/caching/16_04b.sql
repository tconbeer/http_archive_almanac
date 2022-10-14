# standardSQL
# 16_04b: Difference between Cache TTL and the contents age
CREATE TEMPORARY FUNCTION toTimestamp(date_string STRING)
RETURNS INT64 LANGUAGE js AS '''
  try {
    var timestamp = Math.round(new Date(date_string).getTime() / 1000);
    return isNaN(timestamp) ? -1 : timestamp;
  } catch (e) {
    return -1;
  }
''';

select
    client,
    percentile,
    approx_quantiles(diff_in_days, 1000)[offset(percentile * 10)] as diff_in_days
from
    (
        select
            client,
            round(
                (expage - (starteddatetime - totimestamp(resp_last_modified))) / 86400,
                2
            ) as diff_in_days
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and resp_last_modified != '' and expage > 0
    ),
    unnest([10, 20, 30, 40, 50, 60, 70, 80, 90]) as percentile
group by percentile, client
order by percentile, client
