# standardSQL
# Requests with a content age older than its TTL
CREATE TEMPORARY FUNCTION toTimestamp(date_string STRING)
RETURNS INT64 LANGUAGE js AS '''
  try {
    var timestamp = Math.round(new Date(date_string).getTime() / 1000);
    return isNaN(timestamp) || timestamp < 0 ? -1 : timestamp;
  } catch (e) {
    return null;
  }
''';

select
    client,
    count(0) as total_req,
    countif(diff < 0) as req_too_short_cache,
    countif(diff < 0) / count(0) as perc_req_too_short_cache
from
    (
        select
            _table_suffix as client,
            expage - (starteddatetime - totimestamp(resp_last_modified)) as diff
        from `httparchive.summary_requests.2020_08_01_*`
        where resp_last_modified != '' and expage > 0
    )
group by client
order by client
