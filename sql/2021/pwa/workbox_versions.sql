# standardSQL
# Workbox versions
create temporary function getworkboxversions(workboxinfo string)
returns array<string>
language js
as
    '''
try {
  var workboxPackageMethods = Object.values(JSON.parse(workboxInfo));
  if (typeof workboxPackageMethods == 'string') {
    workboxPackageMethods = [workboxPackageMethods];
  }
  var workboxVersions = [];
  /* Replacing spaces and commas */
  for (var i = 0; i < workboxPackageMethods.length; i++) {
      var workboxItems = workboxPackageMethods[i].toString().trim().split(',');
      for(var j = 0; j < workboxItems.length; j++) {
        var workboxItem = workboxItems[j];
        var firstColonIndex = workboxItem.indexOf(':');
        if(firstColonIndex > -1) {
          var workboxVersion = workboxItem.trim().substring(workboxItem.indexOf(':', firstColonIndex + 1) + 1);
          workboxVersions.push(workboxVersion);
        }
      }
  }
  return Array.from(new Set(workboxVersions));
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    workbox_version,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from
    `httparchive.pages.2021_07_01_*`,
    unnest(
        getworkboxversions(json_extract(payload, '$._pwa.workboxInfo'))
    ) as workbox_version
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        where json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
        group by _table_suffix
    ) using (_table_suffix)
where
    json_extract(payload, '$._pwa.workboxInfo') != '[]'
    and json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
group by _table_suffix, workbox_version, total
order by pct desc, client
