# standardSQL
# Workbox package and methods
create temporary function getworkboxpackages(workboxinfo string)
returns array
< string
> language js
as '''
try {
  var workboxPackageMethods = Object.values(JSON.parse(workboxInfo));
  if (typeof workboxPackageMethods == 'string') {
    workboxPackageMethods = [workboxPackageMethods];
  }
  var workboxPackages = [];
  /* Replacing spaces and commas */
  for (var i = 0; i < workboxPackageMethods.length; i++) {
      var workboxItems = workboxPackageMethods[i].toString().trim().split(',');
      for(var j = 0; j < workboxItems.length; j++) {
        var workboxItem = workboxItems[j];
        var firstColonIndex = workboxItem.indexOf(':');
        if(firstColonIndex > -1) {
          var workboxPackage = workboxItem.trim().substring(firstColonIndex + 1, workboxItem.indexOf(':', firstColonIndex + 1));
          workboxPackages.push(workboxPackage);
        }
      }
  }
  return Array.from(new Set(workboxPackages));
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    workbox_package,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from
    `httparchive.pages.2021_07_01_*`,
    unnest(
        getworkboxpackages(json_extract(payload, '$._pwa.workboxInfo'))
    ) as workbox_package
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        where json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
        group by _table_suffix
    )
    using(_table_suffix)
where
    json_extract(payload, '$._pwa.workboxInfo') != '[]' and json_extract(
        payload, '$._pwa.serviceWorkerHeuristic'
    ) = 'true'
group by client, workbox_package, total
order by pct desc, client
