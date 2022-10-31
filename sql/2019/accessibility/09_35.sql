# standardSQL
# 09_35: % of pages with distracting UX (marquee/blink elements, or
# animation-iteration-count: infinite)
create temporary function includesinfiniteanimation(css string)
returns boolean
language js
as '''
try {
  var reduceValues = (values, rule) => {
    if (values) {
      return values;
    }
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    if (!('declarations' in rule)) {
      return values;
    }

    return !!rule.declarations.find(d =>
          d.property.toLowerCase() == 'animation-iteration-count' &&
          d.value.toLowerCase() == 'infinite');
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, false);
} catch (e) {
  return false;
}
'''
;
create temporary function includesmotionelement(payload string)
returns boolean
language js
as '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count);
  if (Array.isArray(elements) || typeof elements != 'object') return [];
  return !!Object.keys(elements).find(e => e == 'marquee' || e == 'blink');
} catch (e) {
  return false;
}
'''
;

select
    client,
    countif(motion) as motion,
    countif(animations > 0) as animations,
    countif(motion or animations > 0) as freq,
    sum(count(distinct page)) over (partition by client) as total,
    round(
        countif(motion or animations > 0)
        * 100
        / sum(count(distinct page)) over (partition by client),
        2
    ) as pct
from
    (
        select
            _table_suffix as client,
            url as page,
            includesmotionelement(payload) as motion
        from `httparchive.pages.2019_07_01_*`
    )
join
    (
        select client, page, countif(includesinfiniteanimation(css)) as animations
        from `httparchive.almanac.parsed_css`
        where date = '2019-07-01'
        group by client, page
    ) using (client, page)
group by client
order by freq / total desc, client
