# standardSQL
# Most popular hosts users dns-prefetch to
# capped to one hit per url to avoid having the results skewed by websites which
# dns-prefetch many resources from the same host
create temporary function getresourcehintshrefs(payload string, hint string)
returns array<string>
language js
as
    '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['link-nodes'].nodes.filter(link => link.rel.toLowerCase() == hint).map(n => n.href);
} catch (e) {
  return [];
}
'''
;

select client, host, freq, total, pct
from
    (
        select
            client,
            host,
            count(0) as freq,
            sum(count(0)) over (partition by client) as total,
            count(0) / sum(count(0)) over (partition by client) as pct,
            row_number() over (partition by client order by count(0) desc) as pos
        from
            (
                select client, url, host
                from
                    (
                        select _table_suffix as client, url, net.host(href) as host
                        from
                            `httparchive.pages.2021_07_01_*`,
                            unnest(
                                getresourcehintshrefs(payload, 'dns-prefetch')
                            ) as href
                    )
                group by client, url, host
            )
        group by client, host
        order by client, freq desc
    )
where pos <= 100
