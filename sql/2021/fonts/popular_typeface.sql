# standardSQL
# popular_typeface
create temporary function getfontfamilies(css string)
returns
    array <
        string > language js
        as
            '''
try {
  var $ = JSON.parse(css);
  return $.stylesheet.rules.filter(rule => rule.type == 'font-face').map(rule => {
    var family = rule.declarations && rule.declarations.find(d => d.property == 'font-family');
    return family && family.value.replace(/[\'"]/g, '');
  }).filter(family => family);
} catch (e) {
  return [];
}
'''
;

select client, font_family, pages, total, pages / total as pct
from
    (
        select client, font_family, count(distinct page) as pages
        from
            `httparchive.almanac.parsed_css`,
            unnest(getfontfamilies(css)) as font_family
        where date = '2021-07-01'
        group by client, font_family
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2021_07_01_*`
        group by client
    ) using (client)
where pages / total >= 0.004
order by pct desc
