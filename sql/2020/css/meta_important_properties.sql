# standardSQL
create temporary function getimportantproperties(css string)
returns
    array<
        struct<
            property string,
            freq int64 >> language js
            options (library = "gs://httparchive/lib/css-utils.js")
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

  return Object.entries(ret.properties).map(([property, freq]) => {
    return {property, freq};
  });
} catch (e) {
  return [];
}
'''
;

select
    client,
    property,
    count(distinct page) as pages,
    sum(freq) as freq,
    sum(sum(freq)) over (partition by client) as total,
    sum(freq) / sum(sum(freq)) over (partition by client) as pct
from
    (
        select client, page, important.property, important.freq
        from
            `httparchive.almanac.parsed_css`,
            unnest(getimportantproperties(css)) as important
        where date = '2020-08-01'
    )
group by client, property
order by pct desc
limit 500
