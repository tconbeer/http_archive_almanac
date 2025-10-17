# standardSQL
# Percent of third-party requests with "Timing-Allow-Origin" headers
# Header reference:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Timing-Allow-Origin
create temp function get_tao(headers string)
returns string
language js
as '''
  try {
    const regex = /timing-allow-origin = (\\*|(http.*?,? )+)/gm;
    output = regex.exec(headers)[1]+", ";
    output = output.replace(/, , $/, ", ");
    return output;
  } catch (e) {
    return false;
  }
'''
;

with
    requests as (
        select
            _table_suffix as client,
            pageid,
            rtrim(urlshort, '/') as origin,
            respotherheaders
        from `httparchive.summary_requests.2020_08_01_*`
    ),

    pages as (
        select _table_suffix as client, pageid, rtrim(urlshort, '/') as origin
        from `httparchive.summary_pages.2020_08_01_*`
    ),

    third_party as (
        select category, domain
        from `httparchive.almanac.third_parties`
        where date = '2020-08-01'
    ),

    headers as (
        select
            requests.client as client,
            requests.origin as req_origin,
            pages.origin as page_origin,
            get_tao(lower(respotherheaders)) as timing_allow_origin,
            third_party.category as req_category
        from requests
        left join pages using (client, pageid)
        inner join
            third_party on net.host(requests.origin) = net.host(third_party.domain)
    ),

    base as (
        select
            client,
            req_origin,
            page_origin,
            timing_allow_origin,
            req_category,
            if(
                page_origin = req_origin
                or timing_allow_origin = '*, '
                or strpos(timing_allow_origin, concat(page_origin, ', ')) > 0,
                1,
                0
            ) as timing_allowed
        from headers
    )

select
    client,
    count(0) as total_requests,
    sum(timing_allowed) / count(0) as pct_timing_allowed_requests
from base
group by client
