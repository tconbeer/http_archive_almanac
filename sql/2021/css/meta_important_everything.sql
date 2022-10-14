# standardSQL
# Stats for pages whose properties all have !important
CREATE TEMPORARY FUNCTION getImportantProperties(css STRING)
RETURNS STRUCT<total INT64, important INT64>
LANGUAGE js
OPTIONS (library = "gs://httparchive/lib/css-utils.js")
AS '''
try {
  var ast = JSON.parse(css);
  let ret = {
    total: 0,
    important: 0,
    properties: {}
  };

  walkDeclarations(ast, ({property, important}) => {
    ret.total++;

    if (important) {
      ret.important++;
      incrementByKey(ret.properties, property);
    }
  });

  ret.properties = sortObject(ret.properties);

  return ret;
} catch (e) {
  return [];
}
''';

select client, total as num_properties_per_page, count(0) as freq
from
    (
        select
            client,
            page,
            sum(properties.important) as important,
            sum(properties.total) as total
        from
            (
                select client, page, getimportantproperties(css) as properties
                from `httparchive.almanac.parsed_css`
                where date = '2021-07-01'
            )
        group by client, page
    )
where important = total and important > 0
group by client, total
order by total
