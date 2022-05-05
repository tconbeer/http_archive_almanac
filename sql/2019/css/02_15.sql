# standardSQL
# 02_15: Top snap points in media queries
create temporary function getsnappoints(css string)
returns array
< string
> language js
as '''
try {
  var reduceValues = (values, rule) => {
    if (rule.type != 'media') {
      return values;
    }

    return values.concat(rule.media.split(',').filter(query => {
      return query.match(/(min|max)-(width|height)/i) && query.match(/\\d+\\w*/);
    }).map(query => {
      return query.match(/\\d+\\w*/)[0]
    }));
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
    snap_point,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.parsed_css`, unnest(getsnappoints(css)) as snap_point
where date = '2019-07-01'
group by client, snap_point
order by freq / total desc
limit 1000
