# standardSQL
# % of pages using each link protocol
CREATE TEMPORARY FUNCTION getUsedProtocols(payload STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
  const almanac = JSON.parse(payload);
  return Object.keys(almanac.link_protocols_used);
} catch (e) {
  return [];
}
''';
select
    _table_suffix as client,
    total_pages,
    protocol,
    count(0) as total_pages_using,
    count(0) / total_pages as pct_pages_using
from
    `httparchive.pages.2021_07_01_*`,
    unnest(getusedprotocols(json_extract_scalar(payload, '$._almanac'))) as protocol
left join
    (
        select _table_suffix, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    ) using (_table_suffix)
group by client, protocol, total_pages
having total_pages_using >= 100
order by pct_pages_using desc
