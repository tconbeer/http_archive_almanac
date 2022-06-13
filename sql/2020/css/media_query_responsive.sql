# standardSQL
create temporary function getmediaqueryfeatures(css string)
returns array < string > language js
options(library = "gs://httparchive/lib/css-utils.js")
as '''
try {
  function compute(ast) {
    let ret = {};

    walkRules(ast, rule => {
      let features = rule.media
                .replace(/\\s+/g, "")
                .match(/\\([\\w-]+(?=[:\\)])/g);

      if (features) {
        features = features.map(s => s.slice(1));

        for (let feature of features) {
          incrementByKey(ret, feature);
        }
      }
    }, {type: "media"});

    return ret;
  }

  const ast = JSON.parse(css);
  let features = compute(ast);
  return Object.keys(features);
} catch (e) {
  return [];
}
'''
;

select client, count(distinct page) as pages, total, count(distinct page) / total as pct
from
    (
        select distinct client, page, lower(feature) as feature
        from `httparchive.almanac.parsed_css`
        left join unnest(getmediaqueryfeatures(css)) as feature
        where date = '2020-08-01' and feature is not null
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
    )
    using
    (client)
where regexp_contains(feature, r'(-width|-height|-aspect-ratio)$')
group by client, total, responsive
