# standardSQL
# Popular PWA script
create temporary function getswlibraries(importscriptsinfo string)
returns array
< string
> language js
as '''
try {
  /* 'importScriptsInfo' returns an array of script that might import other script
      The final array of script comes from the combination of both */
  var ObjKeys = Object.keys(JSON.parse(importScriptsInfo));
  var ObjValues = Object.values(JSON.parse(importScriptsInfo));
  var script = ObjKeys.concat(ObjValues);
  /* Replacing spaces and commas */
  for (var i = 0; i < script.length; i++) {
      script[i] = script[i].toString().trim().replace(/'/g, "");
  }

  /* Creating a Set to eliminate duplicates and transforming back to an array to respect the function signature */
  return Array.from(new Set(script));
} catch (e) {
  return [];
}
'''
;

select
    client,
    countif(workbox > 0) / total as workbox,
    countif(sw_toolbox > 0) / total as sw_toolbox,
    countif(firebase > 0) / total as firebase,
    countif(onesignalsdk > 0) / total as onesignalsdk,
    countif(najva > 0) / total as najva,
    countif(upush > 0) / total as upush,
    countif(cache_polyfill > 0) / total as cache_polyfill,
    countif(analytics_helper > 0) / total as analytics_helper,
    countif(recaptcha > 0) / total as recaptcha,
    countif(pwabuilder > 0) / total as pwabuilder,
    countif(pushprofit > 0) / total as pushprofit,
    countif(sendpulse > 0) / total as sendpulse,
    countif(quora > 0) / total as quora,
    countif(none_of_the_above > 0) / total as none_of_the_above,
    countif(importscripts > 0) / total as uses_importscript,
    total
from
    (
        select
            _table_suffix as client,
            url,
            count(0) as importscripts,
            countif(lower(script) like '%workbox%') as workbox,
            countif(lower(script) like '%sw-toolbox%') as sw_toolbox,
            countif(lower(script) like '%firebase%') as firebase,
            countif(lower(script) like '%onesignalsdk%') as onesignalsdk,
            countif(lower(script) like '%najva%') as najva,
            countif(lower(script) like '%upush%') as upush,
            countif(lower(script) like '%cache-polyfill%') as cache_polyfill,
            countif(lower(script) like '%analytics-helper%') as analytics_helper,
            countif(lower(script) like '%recaptcha%') as recaptcha,
            countif(lower(script) like '%pwabuilder%') as pwabuilder,
            countif(lower(script) like '%pushprofit%') as pushprofit,
            countif(lower(script) like '%sendpulse%') as sendpulse,
            countif(lower(script) like '%quore%') as quora,
            countif(
                lower(script) not like '%workbox%'
                and lower(script) not like '%sw-toolbox%'
                and lower(script) not like '%firebase%'
                and lower(script) not like '%onesignalsdk%'
                and lower(script) not like '%najva%'
                and lower(script) not like '%upush%'
                and lower(script) not like '%cache-polyfill.js%'
                and lower(script) not like '%analytics-helper.js%'
                and lower(script) not like '%recaptcha%'
                and lower(script) not like '%pwabuilder%'
                and lower(script) not like '%pushprofit%'
                and lower(script) not like '%sendpulse%'
                and lower(script) not like '%quora%'
            ) as none_of_the_above
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(
                getswlibraries(json_extract(payload, '$._pwa.importScriptsInfo'))
            ) as script
        where
            json_extract(payload, '$._pwa.importScriptsInfo') != '[]'
            and json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
        group by _table_suffix, url
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        where json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
        group by client
    )
    using(client)
group by client, total
order by client
