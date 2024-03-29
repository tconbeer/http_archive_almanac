# standardSQL
# Difference between Cache TTL and the content age for third party request
create temporary function totimestamp(date_string string)
returns int64
language js
as '''
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
    party,
    count(0) as total_req,
    countif(diff < 0) as req_too_short_cache,
    countif(diff < 0) / count(0) as perc_req_too_short_cache
from
    (
        select
            'desktop' as client,
            if(
                net.host(url) in (
                    select domain
                    from `httparchive.almanac.third_parties`
                    where date = '2020-08-01' and category != 'hosting'
                ),
                'third party',
                'first party'
            ) as party,
            requests.expage - (
                requests.starteddatetime - totimestamp(requests.resp_last_modified)
            ) as diff
        from `httparchive.summary_requests.2020_08_01_desktop` requests
        where trim(requests.resp_last_modified) != '' and expage > 0
        union all
        select
            'mobile' as client,
            if(
                net.host(url) in (
                    select domain
                    from `httparchive.almanac.third_parties`
                    where date = '2020-08-01' and category != 'hosting'
                ),
                'third party',
                'first party'
            ) as party,
            requests.expage - (
                requests.starteddatetime - totimestamp(requests.resp_last_modified)
            ) as diff
        from `httparchive.summary_requests.2020_08_01_mobile` requests
        where trim(requests.resp_last_modified) != '' and expage > 0
    )
group by client, party
order by client, party
