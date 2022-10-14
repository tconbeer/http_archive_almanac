# standardSQL
CREATE TEMPORARY FUNCTION getGlobalKeywords(css STRING)
RETURNS ARRAY<STRUCT<property STRING, keyword STRING, freq INT64>>
LANGUAGE js
OPTIONS (library = "gs://httparchive/lib/css-utils.js")
AS '''
try {
  function compute(ast) {
    let ret = {};

    walkDeclarations(ast, ({property, value}) => {
      let key = value;

      ret[value] = ret[value] || {};

      incrementByKey(ret[value], "total");
      incrementByKey(ret[value], property);
    }, {
      values: ["inherit", "initial", "unset", "revert"]
    });

    for (let keyword in ret) {
      ret[keyword] = sortObject(ret[keyword]);
    }

    return ret;
  }
  var ast = JSON.parse(css);
  var kw = compute(ast);
  return Object.entries(kw).flatMap(([keyword, properties]) => {
    return Object.entries(properties).filter(([property]) => {
      return property != 'total';
    }).map(([property, freq]) => {
      return {property, keyword, freq};
    });
  });
} catch (e) {
  return [];
}
''';

select *, pages / total_pages as pct_pages
from
    (
        select
            client,
            kw.keyword,
            kw.property,
            sum(kw.freq) as freq,
            sum(sum(kw.freq)) over (partition by client, kw.keyword) as total,
            sum(kw.freq)
            / sum(sum(kw.freq)) over (partition by client, kw.keyword) as pct,
            count(distinct page) as pages
        from `httparchive.almanac.parsed_css`, unnest(getglobalkeywords(css)) as kw
        where date = '2020-08-01'
        group by client, keyword, property
    )
join
    (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
    ) using (client)
where pct >= 0.01
order by client, keyword, pct desc
