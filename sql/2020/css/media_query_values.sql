# standardSQL
create temporary function getmediaqueryvalues(css string)
returns array < string > language js
options(library = "gs://httparchive/lib/css-utils.js") as '''
try {
  function compute(ast) {
    let ret = {};

    walkRules(ast, rule => {
      let queries = rule.media
                .replace(/\\s+/g, "")
                .match(/\\(.+?\\)/g);

      if (queries) {
        for (let query of queries) {
          incrementByKey(ret, query);
        }
      }
    }, {type: "media"});

    return ret;
  }

  const ast = JSON.parse(css);
  let values = compute(ast);
  return Object.keys(values);
} catch (e) {
  return [];
}
'''
;

select
    client,
    value,
    count(distinct page) as pages,
    total,
    count(distinct page) / total as pct
from
    (
        select distinct client, page, lower(value) as value
        from `httparchive.almanac.parsed_css`
        left join unnest(getmediaqueryvalues(css)) as value
        where date = '2020-08-01' and value is not null
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
    )
    using
    (client)
group by client, total, value
having pct >= 0.01
order by pct desc
