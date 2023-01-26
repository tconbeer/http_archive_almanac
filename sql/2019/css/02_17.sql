# standardSQL
# 02_17: % of pages using em/rem/px in media queries
create temporary function getunits(css string)
returns struct<em boolean, rem boolean, px boolean>
language js
as '''
try {
  var reduceValues = (values, rule) => {
    if (rule.type != 'media') {
      return values;
    }

    rule.media.split(',').filter(query => {
      return query.match(/(min|max)-(width|height)/i) && query.match(/\\d+(\\w*)/);
    }).forEach(query => {
      var unit = query.match(/\\d+(\\w*)/)[1];
      values[unit] = true;
    });

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
    countif(em > 0) as freq_em,
    countif(rem > 0) as freq_rem,
    countif(px > 0) as freq_px,
    total,
    round(countif(em > 0) * 100 / total, 2) as pct_em,
    round(countif(rem > 0) * 100 / total, 2) as pct_rem,
    round(countif(px > 0) * 100 / total, 2) as pct_px
from
    (
        select
            client,
            countif(unit.em) as em,
            countif(unit.rem) as rem,
            countif(unit.px) as px
        from
            (
                select client, page, getunits(css) as unit
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
    ) using (client)
group by client, total
