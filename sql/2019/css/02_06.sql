# standardSQL
# 02_06: % of sites that use each color format
create temporary function getcolorformats(css string)
returns struct < hsl boolean,
hsla boolean,
rgb boolean,
rgba boolean,
hex boolean
> language js
as '''
try {
  var getColorFormat = (value) => {
    value = value.toLowerCase();
    if (value.includes('hsl(')) {
      return 'hsl';
    }
    if (value.includes('hsla(')) {
      return 'hsla';
    }
    if (value.includes('rgb(')) {
      return 'rgb';
    }
    if (value.includes('rgba(')) {
      return 'rgba';
    }
    if (value.match(/#\\d{3,}/)) {
      return 'hex';
    }
    return null;
  }

  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    if (!('declarations' in rule)) {
      return values;
    }

    rule.declarations.forEach(d => {
      var format = getColorFormat(d.value);
      if (format) {
        values[format] = true;
      }
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
    countif(hsl > 0) as freq_hsl,
    countif(hsla > 0) as freq_hsla,
    countif(rgb > 0) as freq_rgb,
    countif(rgba > 0) as freq_rgba,
    countif(hex > 0) as freq_hex,
    total,
    round(countif(hsl > 0) * 100 / total, 2) as pct_hsl,
    round(countif(hsla > 0) * 100 / total, 2) as pct_hsla,
    round(countif(rgb > 0) * 100 / total, 2) as pct_rgb,
    round(countif(rgba > 0) * 100 / total, 2) as pct_rgba,
    round(countif(hex > 0) * 100 / total, 2) as pct_hex
from
    (
        select
            client,
            countif(color.hsl) as hsl,
            countif(color.hsla) as hsla,
            countif(color.rgb) as rgb,
            countif(color.rgba) as rgba,
            countif(color.hex) as hex
        from
            (
                select client, page, getcolorformats(css) as color
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
