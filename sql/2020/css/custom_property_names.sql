# standardSQL
# Most popular custom property names as a percent of pages.
create temporary function getcustompropertynames(payload string) returns array
< string
> language js
as '''
try {
  var $ = JSON.parse(payload);
  var vars = JSON.parse($['_css-variables']);
  return Object.keys(vars.summary);
} catch (e) {
  return [];
}
'''
;

select
    client, name, count(distinct url) as freq, total, count(distinct url) / total as pct
from
    (
        select
            _table_suffix as client,
            url,
            getcustompropertynames(payload) as names,
            total
        from `httparchive.pages.2020_08_01_*`
        join
            (
                select _table_suffix, count(distinct url) as total
                from `httparchive.pages.2020_08_01_*`
                group by _table_suffix
            )
            using(_table_suffix)
    ),
    unnest(names) as name
group by client, name, total
order by pct desc
limit 1000
