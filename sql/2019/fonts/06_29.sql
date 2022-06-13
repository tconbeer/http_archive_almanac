# standardSQL
# 06_29: Variation axes used for +/- 20 pt
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
    regexp_extract(lower(value), '[\'"]([\\w]{4})[\'"]') as axis,
    countif(cast(regexp_extract(value, '\\d+') as numeric) < 6) as freq_under_6,
    countif(
        cast(regexp_extract(value, '\\d+') as numeric) between 6 and 19
    ) as freq_between_6_20,
    countif(cast(regexp_extract(value, '\\d+') as numeric) >= 20) as freq_over_20,
    sum(count(0)) over (partition by client) as total,
    round(
        countif(cast(regexp_extract(value, '\\d+') as numeric) < 6) * 100 / sum(
            count(0)
        ) over (partition by client),
        2
    ) as pct_under_6,
    round(
        countif(
            cast(regexp_extract(value, '\\d+') as numeric) between 6 and 19
        ) * 100 / sum(count(0)) over (partition by client),
        2
    ) as pct_between_6_20,
    round(
        countif(cast(regexp_extract(value, '\\d+') as numeric) >= 20) * 100 / sum(
            count(0)
        ) over (partition by client),
        2
    ) as pct_over_20
from
    `httparchive.almanac.parsed_css`,
    unnest(getfontvariationsettings(css)) as values,
    unnest(split(values, ',')) as value
where date = '2019-07-01'
group by client, axis
having axis is not null
order by freq_between_6_20 / total desc
