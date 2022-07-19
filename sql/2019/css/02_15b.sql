# standardSQL
# 02_15b: % of pages using landscape/portrait orientation in media queries
create temporary function getorientation(css string)
returns struct < landscape boolean,
portrait boolean
> language js as '''
try {
  var reduceValues = (values, rule) => {
    if (rule.type != 'media') {
      return values;
    }

    if (rule.media.toLowerCase().includes('landscape')) {
      values['landscape'] = true;
    }
    if (rule.media.toLowerCase().includes('portrait')) {
      values['portrait'] = true;
    }
    return values;
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, {});
} catch (e) {
  return {};
}
'''
;

select
    client,
    countif(landscape > 0) as freq_landscape,
    countif(portrait > 0) as freq_portrait,
    countif(landscape > 0 and portrait > 0) as freq_both,
    total,
    round(countif(landscape > 0) * 100 / total, 2) as pct_landscape,
    round(countif(portrait > 0) * 100 / total, 2) as pct_portrait,
    round(countif(landscape > 0 and portrait > 0) * 100 / total, 2) as pct_both
from
    (
        select
            client,
            countif(orientation.landscape) as landscape,
            countif(orientation.portrait) as portrait
        from
            (
                select client, page, getorientation(css) as orientation
                from `httparchive.almanac.parsed_css`
                where date = '2019-07-01'
            )
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by client
    )
    using
    (client)
group by client, total
