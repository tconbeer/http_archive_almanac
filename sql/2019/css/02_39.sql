# standardSQL
# 02_39: Distribution of media queries per page
CREATE TEMPORARY FUNCTION getMediaQueries(css STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce((values, rule) => {
    if (rule.type == 'media') {
      values.push(rule.media);
    }
    return values;
  }, []);
} catch (e) {
  return [];
}
''';

select
    client,
    approx_quantiles(media_queries, 1000)[offset(100)] as p10,
    approx_quantiles(media_queries, 1000)[offset(250)] as p25,
    approx_quantiles(media_queries, 1000)[offset(500)] as p50,
    approx_quantiles(media_queries, 1000)[offset(750)] as p75,
    approx_quantiles(media_queries, 1000)[offset(900)] as p90
from
    (
        select client, count(distinct value) as media_queries
        from `httparchive.almanac.parsed_css`
        left join unnest(getmediaqueries(css)) as value
        where date = '2019-07-01'
        group by client, page
    )
group by client
