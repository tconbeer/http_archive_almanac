# standardSQL
# Usage of client hint directives
create temporary function getclienthints(headers string)
returns array
< string
> language js
as """
try {
  const header_name = 'Accept-CH';
  const parsed_headers = JSON.parse(headers);
  const matching_headers = parsed_headers.filter(h => h.name.toLowerCase() == header_name.toLowerCase());
  if (matching_headers.length <= 0) {
    return [];
  }

  const unique_directives = new Set();
  for (const header of matching_headers) {
    const directives = header.value.split(/\\s*,\\s*/);
    for (const directive of directives) {
      unique_directives.add(directive.toLowerCase());
    }
  }

  return Array.from(unique_directives);
} catch (e) {
  return [];
}
"""
;

select
    client,
    total_pages,
    sum(count(distinct page)) over (partition by client) as total_pages_using_ch,

    ch_directive,
    count(0) as total_pages_using,
    count(0) / total_pages as pct_pages,
    count(0)
    / sum(count(distinct page)) over (partition by client) as pct_ch_pages_using
from
    (
        select page, client, ch_directive
        from
            `httparchive.almanac.requests`,
            unnest(
                getclienthints(json_extract(payload, '$.response.headers'))
            ) as ch_directive
        where date = '2021-07-01' and firsthtml
    )
left join
    (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    ) using (client)
group by client, ch_directive, total_pages
order by pct_pages desc
