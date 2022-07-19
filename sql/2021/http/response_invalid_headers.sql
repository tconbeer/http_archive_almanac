# standardSQL
# List of invalid header names containing either a space or non-ASCII characters
create temporary function extracthttpheaders(httpheaders string)
returns array
< string
> language js as """
try {
  var headers = JSON.parse(HTTPheaders);

  // Filter by header name (which is case insensitive)
  // If multiple headers it's the same as comma separated
  return headers.map(h => h.name.toLowerCase());

} catch (e) {
  return "";
}
"""
;

select
    client,
    header,
    count(0) as num_requests,
    total,
    count(0) / total as pct,
    array_to_string(array_agg(distinct url limit 5), ' ') as sample_urls
from
    `httparchive.almanac.requests`,
    unnest(extracthttpheaders(response_headers)) as header
join
    (
        select client, count(0) as total
        from `httparchive.almanac.requests`
        group by client
    )
    using(client)
where
    date = '2021-07-01'
    and (
        (
            header like '% %'
            and header not like 'http/1.1 %'
            and header not like 'http/1.0 %'
        )
        or (regexp_replace(header, r'([^\p{ASCII}]+)', '') != header)
    )
group by client, header, total
order by pct desc, client
limit 1000
