# standardSQL
# Workbox methods
create temporary function getworkboxmethods(workboxinfo string)
returns array
< string
> language js as '''
try {
  var workboxPackageMethods = Object.values(JSON.parse(workboxInfo));
  if (typeof workboxPackageMethods == 'string') {
    workboxPackageMethods = [workboxPackageMethods];
  }
  var workboxMethods = [];
  /* Replacing spaces and commas */
  for (var i = 0; i < workboxPackageMethods.length; i++) {
      var workboxItems = workboxPackageMethods[i].toString().trim().split(',');
      for(var j = 0; j < workboxItems.length; j++) {
        if(workboxItems[j].indexOf(':') == -1) {
          if (workboxItems[j].trim().startsWith('workbox.')) {
            workboxMethods.push(workboxItems[j].trim().substring(8));
          }
        }
      }
  }
  return Array.from(new Set(workboxMethods));
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    workbox_method,
    regexp_extract(workbox_method, r'^([^.]+)') as module_only,
    regexp_extract(workbox_method, r'^[^.]+\.([^.]+)') as method_only,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from
    `httparchive.pages.2021_07_01_*`,
    unnest(
        getworkboxmethods(json_extract(payload, '$._pwa.workboxInfo'))
    ) as workbox_method
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        where json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
        group by _table_suffix
    )
    using(_table_suffix)
where
    json_extract(payload, '$._pwa.workboxInfo') != '[]'
    and json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
group by client, workbox_method, total
order by pct desc, client
