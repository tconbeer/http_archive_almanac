# standardSQL
# Popularity of @keyframes positions
create temporary function getkeyframepositions(css string) returns array
< string
> language js as r'''
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }

    if (rule.type != 'keyframes') {
      return values;
    }

    var positions = rule.keyframes.flatMap(keyframe => {
      return keyframe.values;
    });
    return values.concat(positions);
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, []);
} catch (e) {
  return [];
}
'''
;

select *
from
    (
        select
            client,
            position,
            count(distinct page) as pages,
            any_value(total) as total_pages,
            count(distinct page) / any_value(total) as pct_pages,
            count(0) as freq,
            sum(count(0)) over (partition by client) as total,
            count(0) / sum(count(0)) over (partition by client) as pct
        from
            `httparchive.almanac.parsed_css`,
            unnest(getkeyframepositions(css)) as position
        join
            (
                select _table_suffix as client, count(0) as total
                from `httparchive.summary_pages.2021_07_01_*`
                group by client
            ) using (client)
        where date = '2021-07-01'
        group by client, position
        order by pct desc
    )
limit 500
