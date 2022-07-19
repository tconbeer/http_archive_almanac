# standardSQL
# How often pages contain an element with a given attribute
create temporary function getusedattributes(payload string)
returns array
< string
> language js as '''
try {
  const almanac = JSON.parse(payload);
  return Object.keys(almanac.attributes_used_on_elements);
} catch (e) {
  return [];
}
'''
;
select
    _table_suffix as client,
    total_sites,
    attribute,
    count(0) as total_sites_using,
    count(0) / total_sites as pct_sites_using
from
    `httparchive.pages.2020_08_01_*`,
    unnest(getusedattributes(json_extract_scalar(payload, '$._almanac'))) as attribute
left join
    (
        select _table_suffix, count(0) as total_sites
        from `httparchive.pages.2020_08_01_*`
        group by _table_suffix
    )
    using(_table_suffix)
group by client, attribute, total_sites
having starts_with(attribute, 'aria-') or pct_sites_using >= 0.01
order by pct_sites_using desc
