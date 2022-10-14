# standardSQL
# Percent of third-party requests with "Timing-Allow-Origin" headers
# Header reference:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Timing-Allow-Origin
CREATE TEMP FUNCTION get_tao(headers STRING)
RETURNS STRING LANGUAGE js AS '''
  try {
    const regex = /timing-allow-origin = (\\*|(http.*?,? )+)/gm;
    output = regex.exec(headers)[1]+", ";
    output = output.replace(/, , $/, ", ");
    return output;
  } catch (e) {
    return false;
  }
''';

with
    requests as (
        select
            _table_suffix as client,
            pageid as page,
            url,
            rtrim(urlshort, '/') as origin,
            respotherheaders
        from `httparchive.summary_requests.2021_07_01_*`
    ),

    pages as (
        select
            _table_suffix as client, url, pageid as page, rtrim(urlshort, '/') as origin
        from `httparchive.summary_pages.2021_07_01_*`
    ),

    third_party as (
        select domain, category, count(distinct page) as page_usage
        from `httparchive.almanac.third_parties` tp
        join requests r on net.host(r.url) = net.host(tp.domain)
        where date = '2021-07-01' and category != 'hosting'
        group by domain, category
        having page_usage >= 50
    ),

    headers as (
        select
            requests.client as client,
            requests.origin as req_origin,
            pages.origin as page_origin,
            get_tao(lower(respotherheaders)) as timing_allow_origin,
            third_party.category as req_category
        from requests
        left join pages using (client, page)
        inner join
            third_party on net.host(requests.origin) = net.host(third_party.domain)
    ),

    base as (
        select
            client,
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
    sum(timing_allowed) as timing_allowed_requests,
    count(0) as total_requests,
    sum(timing_allowed) / count(0) as pct_timing_allowed_requests
from base
group by client
