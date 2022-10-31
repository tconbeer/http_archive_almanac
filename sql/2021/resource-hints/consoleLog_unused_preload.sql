# standardSQL
# returns the number of unused preloaded resources
create temporary function getresourcehints(payload string)
returns
    struct<
        preload boolean,
        prefetch boolean,
        preconnect boolean,
        prerender boolean,
        `dns-prefetch` boolean,
        `modulepreload` boolean
    >
language js
as
    '''
var hints = ['preload', 'prefetch', 'preconnect', 'prerender', 'dns-prefetch', 'modulepreload'];
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return hints.reduce((results, hint) => {
    results[hint] = !!almanac['link-nodes'].nodes.find(link => link.rel.toLowerCase() == hint);
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
    array_length(value) as num_unused_preload,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            client,
            regexp_extract_all(
                consolelog,
                r'The resource (.*?) was preloaded using link preload but not used within a few seconds from the window\'s load event'
            ) as value
        from
            (
                select
                    _table_suffix as client,
                    json_extract(payload, '$._consoleLog') as consolelog,
                    getresourcehints(payload) as hints
                from `httparchive.pages.2021_07_01_*`
            )
        where hints.preload
    )
group by client, num_unused_preload
order by client, num_unused_preload
