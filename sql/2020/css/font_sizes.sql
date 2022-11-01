# standardSQL
create temporary function getfontsizes(css string)
returns array<string>
language js
options (library = "gs://httparchive/lib/css-utils.js")
as '''
try {
  var ast = JSON.parse(css);
  var fontSizes = [];
  walkDeclarations(ast, ({property, value}) => {
    for (let fontSize of value.matchAll(/^(?<px>[\\d]+)(px|.\\d+px)/g)) {
      fontSizes.push(fontSize.groups.px);
    }
  }, {properties: /^font/});
  return fontSizes;
} catch (e) {
  return [];
}
'''
;

select
    percentile,
    client,
    approx_quantiles(px, 1000)[offset(percentile * 10)] as font_size_px,
    approx_quantiles(length(px), 1000)[offset(percentile * 10)] as font_size_digits
from
    `httparchive.almanac.parsed_css`,
    unnest(getfontsizes(css)) as px,
    unnest([10, 25, 50, 75, 90, 100]) as percentile
where date = '2020-08-01'
group by percentile, client
order by percentile, client
