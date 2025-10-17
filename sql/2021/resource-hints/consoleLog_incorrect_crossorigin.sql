# standardSQL
# returns the number of pages using preload tags without the required crossorigin
# attribute
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
    array_length(value) as num_incorrect_crossorigin,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            client,
            regexp_extract_all(
                consolelog,
                r'A preload for (.+?) is found, but is not used because the request credentials mode does not match'
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
group by client, num_incorrect_crossorigin
order by client, freq desc
