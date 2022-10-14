# standardSQL
# 06_10: % of pages that declare a font with italics
CREATE TEMPORARY FUNCTION getFonts(css STRING)
RETURNS ARRAY<STRUCT<weight STRING, style STRING>> LANGUAGE js AS '''
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

    var props = {};
    rule.declarations.forEach(d => {
      if (d.property.toLowerCase() == 'font-weight') {
        props.weight = d.value;
      } else if (d.property.toLowerCase() == 'font-style') {
        props.style = d.value;
      }
    });
    if (props.weight && props.style) {
      values.push(props);
    }
    return values;
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, []);
} catch (e) {
  return [];
}
''';

select
    client,
    countif(italic > 0) as freq_italic,
    countif(oblique > 0) as freq_oblique,
    countif(style_normal > 0) as freq_style_normal,
    countif(weight_400_normal > 0) as freq_weight_400_normal,
    countif(weight_700_bold > 0) as freq_weight_700_bold,
    countif(lighter > 0) as freq_lighter,
    countif(bolder > 0) as freq_bolder,
    total,
    round(countif(italics > 0) * 100 / total, 2) as pct_italic,
    round(countif(oblique > 0) * 100 / total, 2) as pct_oblique,
    round(countif(style_normal > 0) * 100 / total, 2) as pct_style_normal,
    round(countif(weight_400_normal > 0) * 100 / total, 2) as pct_weight_400_normal,
    round(countif(weight_700_bold > 0) * 100 / total, 2) as pct_weight_700_bold,
    round(countif(lighter > 0) * 100 / total, 2) as pct_lighter,
    round(countif(bolder > 0) * 100 / total, 2) as pct_bolder
from
    (
        select
            client,
            countif(font.style = 'italic') as italic,
            countif(font.style = 'oblique') as oblique,
            countif(font.style = 'normal') as style_normal,
            countif(font.weight = 'normal' or font.weight = '400') as weight_400_normal,
            countif(font.weight = 'bold' or font.weight = '700') as weight_700_bold,
            countif(cast(font.weight as numeric) > 400) as bolder,
            countif(cast(font.weight as numeric) < 400) as lighter
        from `httparchive.almanac.parsed_css`, unnest(getfonts(css)) as font
        where date = '2019-07-01'
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (client)
group by client, total
