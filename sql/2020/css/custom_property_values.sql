# standardSQL
# Most popular custom property values as a percent of pages.
create temporary function getcustompropertyvalues(payload string) returns array
< string
> language js as '''
try {
  var $ = JSON.parse(payload);
  var vars = JSON.parse($['_css-variables']);
  return Object.values(vars.summary);
} catch (e) {
  return [];
}
'''
;

select
    client,
    value,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from
    (
        select _table_suffix as client, url, getcustompropertyvalues(payload) as
        values, total
        from `httparchive.pages.2020_08_01_*`
        join
            (
                select _table_suffix, count(distinct url) as total
                from `httparchive.pages.2020_08_01_*`
                group by _table_suffix
            ) using (_table_suffix)
    ),
    unnest(values) as value
group by client, value, total
order by pct desc
limit 1000
