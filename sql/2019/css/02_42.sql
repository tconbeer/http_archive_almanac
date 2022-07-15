# standardSQL
# 02_42: Distribution of keyframes per page
create temporary function getkeyframes(css string)
returns array
< string
> language js as '''
try {
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce((values, rule) => {
    if (rule.type == 'keyframes') {
      values.push(rule.name);
    }
    return values;
  }, []);
} catch (e) {
  return [];
}
'''
;

select
    client,
    approx_quantiles(keyframes, 1000) [offset (100)] as p10,
    approx_quantiles(keyframes, 1000) [offset (250)] as p25,
    approx_quantiles(keyframes, 1000) [offset (500)] as p50,
    approx_quantiles(keyframes, 1000) [offset (750)] as p75,
    approx_quantiles(keyframes, 1000) [offset (900)] as p90
from
    (
        select client, count(distinct value) as keyframes
        from `httparchive.almanac.parsed_css`
        left join unnest(getkeyframes(css)) as value
        where date = '2019-07-01'
        group by client, page
    )
group by client
