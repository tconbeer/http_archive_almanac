# standardSQL
# 02_16: % of pages using min/max-width in media queries
create temporary function getmediatype(css string)
returns struct < max_width boolean,
min_width boolean
> language js
as '''
try {
  var reduceValues = (values, rule) => {
    if (rule.type != 'media') {
      return values;
    }

    if (rule.media.toLowerCase().includes('max-width')) {
      values['max_width'] = true;
    }
    if (rule.media.toLowerCase().includes('min-width')) {
      values['min_width'] = true;
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
    countif(max_width > 0) as freq_max_width,
    countif(min_width > 0) as freq_min_width,
    countif(max_width > 0 and min_width > 0) as freq_both,
    total,
    round(countif(max_width > 0) * 100 / total, 2) as pct_max_width,
    round(countif(min_width > 0) * 100 / total, 2) as pct_min_width,
    round(countif(max_width > 0 and min_width > 0) * 100 / total, 2) as pct_both
from
    (
        select
            client,
            countif(type.max_width) as max_width,
            countif(type.min_width) as min_width
        from
            (
                select client, page, getmediatype(css) as type
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
