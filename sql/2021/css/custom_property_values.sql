# standardSQL
# Most popular custom property values as a percent of pages.
create temporary function getcustompropertyvalues(json string) returns array
< string
> language js
as '''
try {
  var vars = JSON.parse(json);
  return Object.values(vars.summary).map(val => val.set[0].value)
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
        select
            _table_suffix as client,
            url,
            getcustompropertyvalues(
                json_value(payload, '$."_css-variables"')
            ) as values,
            total
        from `httparchive.pages.2021_07_01_*`
        join
            (
                select _table_suffix, count(distinct url) as total
                from `httparchive.pages.2021_07_01_*`
                group by _table_suffix
            )
            using(_table_suffix)
    ),
    unnest(values) as value
group by client, value, total
order by pct desc
limit 1000
