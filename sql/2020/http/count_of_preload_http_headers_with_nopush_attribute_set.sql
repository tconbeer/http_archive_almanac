# standardSQL
# Count of preload HTTP Headers with nopush attribute set. Once off stat for last crawl
create temporary function getlinkheaders(payload string)
returns array<string>
language js
as """
try {
  var $ = JSON.parse(payload);
  var headers = $.response.headers;
  return headers.filter(h => h.name.toLowerCase() == 'link').map(h => h.value);
} catch (e) {
  return [];
}
"""
;

select
    client,
    countif(link_header like '%nopush%') as num_nopush,
    count(0) as total_preload,
    round(countif(link_header like '%nopush%') / count(0), 4) as pct_nopush
from
    (
        select client, getlinkheaders(payload) as link_headers
        from `httparchive.almanac.requests`
        where date = '2020-08-01' and firsthtml
    ),
    unnest(link_headers) as link_header
where link_header like '%preload%'
group by client
