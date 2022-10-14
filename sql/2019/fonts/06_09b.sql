# standardSQL
# 06_09b: Distribution of duplicate font-family values per page (see 02_35)
CREATE TEMPORARY FUNCTION getFonts(css STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    if (!('declarations' in rule)) {
      return values;
    }
    if (rule.type != 'font-face') {
      return values;
    }
    return values.concat(rule.declarations.filter(d => d.property.toLowerCase() == 'font-family').map(d => d.value));
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, []);
} catch (e) {
  return [];
}
''';

select
    percentile,
    client,
    approx_quantiles(fonts, 1000)[offset(percentile * 10)] as font_families_per_page
from
    (
        select client, page, count(distinct value) as fonts
        from `httparchive.almanac.parsed_css`
        left join unnest(getfonts(css)) as value
        where date = '2019-07-01'
        group by client, page
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
