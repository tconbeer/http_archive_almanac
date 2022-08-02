# standardSQL
# 02_07: % of sites that use each length unit
create temporary function getlengthunit(css string)
returns array
< string
> language js as '''
try {
  // https://developer.mozilla.org/en-US/docs/Web/CSS/length
  var units = ['cap', 'ch', 'em', 'ex', 'ic', 'lh', 'rem',
      'rlh', 'vh', 'vw', 'vi', 'vb', 'vmin', 'vmax',
      'px', 'cm', 'nm', 'Q', 'in', 'pc', 'pt'];
  units = new Map(units.map(u => {
    return [u, new RegExp(`\\\\d${u}\\\\b`)];
  }));
  var getLengthUnit = (value) => {
    for ([unit, re] of units) {
      if (value.match(re)) {
        return unit;
      }
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
      if (d.value.length > 20) return;
      var unit = getLengthUnit(d.value);
      if (unit) {
        values[unit] = true;
      }
    });
    return values;
  };
  var $ = JSON.parse(css);
  return Object.keys($.stylesheet.rules.reduce(reduceValues, {}));
} catch (e) {
  return [];
}
'''
;

select client, unit, freq, total, round(freq * 100 / total, 2) as pct
from
    (
        select client, unit, count(distinct page) as freq
        from `httparchive.almanac.parsed_css`, unnest(getlengthunit(css)) as unit
        where date = '2019-07-01'
        group by client, unit
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by client
    ) using (client)
order by freq / total desc
