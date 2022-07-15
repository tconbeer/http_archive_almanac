# standardSQL
# VF_axis_value
create temporary function getfontvariationsettings(css string)
returns array
< string
> language js
as '''
try {
    var reduceValues = (values, rule) => {
        if ('rules' in rule) {
            return rule.rules.reduce(reduceValues, values);
        }
        if (!('declarations' in rule)) {
            return values;
        }
        return values.concat(rule.declarations.filter(d => d.property.toLowerCase() == 'font-variation-settings').map(d => d.value));
    };
    var $ = JSON.parse(css);
    return $.stylesheet.rules.reduce(reduceValues, []);
} catch (e) {
    return [];
}
'''
;
select
    client,
    regexp_extract(lower(values), '[\'"]([\\w]{4})[\'"]') as axis,
    cast(regexp_extract(value, '\\d+') as numeric) as num_axis,
    count(distinct page) as pages,
    sum(count(distinct page)) over (partition by client) as total,
    count(distinct page) / sum(count(distinct page)) over (partition by client) as pct
from
    `httparchive.almanac.parsed_css`,
    unnest(getfontvariationsettings(css)) as value,
    unnest(split(value, ',')) as values
where date = '2021-07-01'
group by client, axis, num_axis
having axis is not null
order by pages desc
