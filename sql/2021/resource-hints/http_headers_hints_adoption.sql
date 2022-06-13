# standardSQL
# Retrieves resource hints from HTTP headers
create temporary function getresourcehints(payload string)
returns struct < preload boolean,
prefetch boolean,
preconnect boolean,
prerender boolean,
`dns-prefetch` boolean,
`modulepreload` boolean
>
language js
as '''
var hints = ['preload', 'prefetch', 'preconnect', 'prerender', 'dns-prefetch', 'modulepreload'];
var re = new RegExp(`(${hints.map(hint => `\\\\b${hint}\\\\b`).join('|')})`, 'ig');
try {
  var $ = JSON.parse(payload);
  return $.response.headers.filter(({name, value}) => name.toLowerCase() == 'link' && re.test(value)).reduce((results, {name, value}) => {
    var hint = value.match(re)[0].toLowerCase();
    results[hint] = true;
    return results;
  }, {});
} catch (e) {
  return hints.reduce((results, hint) => {
    results[hint] = false;
    return results;
  }, {});
}
'''
;

select
    client,
    count(0) as total,
    countif(hints.preload) as preload,
    countif(hints.preload) / count(0) as pct_preload,
    countif(hints.prefetch) as prefetch,
    countif(hints.prefetch) / count(0) as pct_prefetch,
    countif(hints.preconnect) as preconnect,
    countif(hints.preconnect) / count(0) as pct_preconnect,
    countif(hints.prerender) as prerender,
    countif(hints.prerender) / count(0) as pct_prerender,
    countif(hints.`dns-prefetch`) as dns_prefetch,
    countif(hints.`dns-prefetch`) / count(0) as pct_dns_prefetch,
    countif(hints.modulepreload) as modulepreload,
    countif(hints.modulepreload) / count(0) as pct_modulepreload
from
    (
        select client, getresourcehints(payload) as hints
        from `httparchive.almanac.requests`
        where payload is not null and firsthtml
    )
group by client
