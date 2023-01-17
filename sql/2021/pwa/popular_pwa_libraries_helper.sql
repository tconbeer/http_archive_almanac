# standardSQL
# Use this sql to find popular library imports for popular_pwa_libraries.sql
# And also other importscripts used in service workers
create temporary function getswlibraries(importscriptsinfo string)
returns array<string>
language js
as
    '''
try {
  /* 'importScriptsInfo' returns an array of libraries that might import other libraries
      The final array of libraries comes from the combination of both */
  var ObjKeys = Object.keys(JSON.parse(importScriptsInfo));
  var ObjValues = Object.values(JSON.parse(importScriptsInfo));
  var libraries = ObjKeys.concat(ObjValues);
  /* Replacing spaces and commas */
  for (var i = 0; i < libraries.length; i++) {
      libraries[i] = libraries[i].toString().trim().replace(/'/g, "");
  }

  /* Creating a Set to eliminate duplicates and transforming back to an array to respect the function signature */
  return Array.from(new Set(libraries));
} catch (e) {
  return [];
}
'''
;

select _table_suffix as client, script, count(distinct url) as freq
from
    `httparchive.pages.2021_07_01_*`,
    unnest(getswlibraries(json_extract(payload, '$._pwa.importScriptsInfo'))) as script
where
    json_extract(payload, '$._pwa.importScriptsInfo') != '[]'
    and json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
    and lower(script) not like '%workbox%'
    and lower(script) not like '%sw-toolbox%'
    and lower(script) not like '%firebase%'
    and lower(script) not like '%onesignalsdk%'
    and lower(script) not like '%najva%'
    and lower(script) not like '%upush%'
    and lower(script) not like '%cache-polyfill.js%'
    and lower(script) not like '%analytics-helper.js%'
    and lower(script) not like '%recaptcha%'
    and lower(script) not like '%pwabuilder%'
group by _table_suffix, script
order by freq desc
