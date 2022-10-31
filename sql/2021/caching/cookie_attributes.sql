# standardSQL
# Popularity of top Set-Cookie attributes/directives
create temporary function getcookieattributes(headers string)
returns array<string> deterministic
language js
as '''
try {
  var $ = JSON.parse(headers);
  return $.filter(header => {
    return header.name.toLowerCase() == 'set-cookie';
  }).flatMap(header => {
    return Array.from(new Set(header.value.split(';').slice(1).map(attr => {
      return attr.trim().split('=')[0].trim();
    })));
  });
} catch (e) {
  return [];
}
'''
;

create temporary function countcookies(headers string)
returns int64 deterministic
language js
as '''
try {
  var $ = JSON.parse(headers);
  return $.filter(header => {
    return header.name.toLowerCase() == 'set-cookie';
  }).length;
} catch (e) {
  return 0;
}
'''
;

select client, attr.value as attr, attr.count as freq, total, attr.count / total as pct
from
    (
        select client, approx_top_count(attr, 100) as attrs
        from
            `httparchive.almanac.requests`,
            unnest(getcookieattributes(response_headers)) as attr
        where date = '2021-07-01'
        group by client
    )
join
    (
        select client, sum(countcookies(response_headers)) as total
        from `httparchive.almanac.requests`
        group by client
    ) using (client),
    unnest(attrs) as attr
order by pct desc
