# standardSQL
# SW registration properties
CREATE TEMPORARY FUNCTION getSWRegistrationProperties(swRegistrationPropertiesInfo STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
  var swRegistrationProperties = Object.values(JSON.parse(swRegistrationPropertiesInfo));
  if (typeof swRegistrationProperties != 'string') {
    swRegistrationProperties = swRegistrationProperties.toString();
  }
  swRegistrationProperties = swRegistrationProperties.trim().split(',').map(x => x.split('.')[0]);
  return Array.from(new Set(swRegistrationProperties));
} catch (e) {
  return [];
}
''';

select
    _table_suffix as client,
    sw_registration_properties,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from
    `httparchive.pages.2021_07_01_*`,
    unnest(
        getswregistrationproperties(
            json_extract(payload, '$._pwa.swRegistrationPropertiesInfo')
        )
    ) as sw_registration_properties
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        where json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
        group by _table_suffix
    ) using (_table_suffix)
where
    json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
    and json_extract(payload, '$._pwa.swRegistrationPropertiesInfo') != '[]'
group by client, total, sw_registration_properties
order by freq / total desc, client
