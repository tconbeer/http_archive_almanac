# standardSQL
# Popularity of top Set-Cookie names
CREATE TEMPORARY FUNCTION getCookies(headers STRING)
RETURNS ARRAY<STRING> DETERMINISTIC LANGUAGE js AS '''
try {
  var $ = JSON.parse(headers);
  return $.filter(header => {
    return header.name.toLowerCase() == 'set-cookie';
  }).map(header => {
    return header.value.split('=')[0].trim();
  });
} catch (e) {
  return [];
}
''';

select
    client,
    cookie.value as cookie,
    cookie.count as freq,
    total,
    cookie.count / total as pct
from
    (
        select client, approx_top_count(cookie, 100) as cookies, count(0) as total
        from
            `httparchive.almanac.requests`,
            unnest(getcookies(response_headers)) as cookie
        where date = '2021-07-01'
        group by client
    ),
    unnest(cookies) as cookie
order by pct desc
