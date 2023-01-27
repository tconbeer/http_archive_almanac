# standardSQL
# 16_04a_3rd_party: Requests with a content age older than its TTL by party
create temporary function totimestamp(date_string string)
returns int64
language js
as '''
  try {
    var timestamp = Math.round(new Date(date_string).getTime() / 1000);
    return isNaN(timestamp) ? -1 : timestamp;
  } catch (e) {
    return -1;
  }
'''
;

select
    client,
    party,
    count(0) as total_req,
    countif(diff < 0) as req_too_short_cache,
    round(countif(diff < 0) * 100 / count(0), 2) as perc_req_too_short_cache
from
    (
        select
            client,
            if(
                strpos(net.host(url), regexp_extract(net.reg_domain(page), r'([\w-]+)'))
                > 0,
                1,
                3
            ) as party,
            expage - (starteddatetime - totimestamp(resp_last_modified)) as diff
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and resp_last_modified != '' and expage > 0
    )
group by client, party
order by client, party
