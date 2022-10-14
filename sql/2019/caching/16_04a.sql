# standardSQL
# 16_04a: Requests with a content age older than its TTL
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
    count(0) as total_req,
    countif(diff < 0) as req_too_short_cache,
    round(countif(diff < 0) * 100 / count(0), 2) as perc_req_too_short_cache
from
    (
        select
            client, expage - (starteddatetime - totimestamp(resp_last_modified)) as diff
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and resp_last_modified != '' and expage > 0
    )
group by client
