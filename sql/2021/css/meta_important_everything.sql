# standardSQL
# Stats for pages whose properties all have !important
create temporary function getimportantproperties(css string)
returns struct < total int64,
important int64 > language js
options(library = "gs://httparchive/lib/css-utils.js")
as '''
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
'''
;

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
