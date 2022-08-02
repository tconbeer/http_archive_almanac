# standardSQL
# % of sites using each type of aria role
create temporary function getusedroles(payload string)
returns array
< string
> language js as '''
try {
  const almanac = JSON.parse(payload);
  return Object.keys(almanac.nodes_using_role.usage_and_count);
} catch (e) {
  return [];
}
'''
;
select
    _table_suffix as client,
    total_sites,
    role,
    count(0) as total_sites_using,
    count(0) / total_sites as pct_sites_using
from
    `httparchive.pages.2021_07_01_*`,
    unnest(getusedroles(json_extract_scalar(payload, '$._almanac'))) as role
left join
    (
        select _table_suffix, count(0) as total_sites
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    ) using (_table_suffix)
group by client, role, total_sites
having total_sites_using >= 100
order by pct_sites_using desc
