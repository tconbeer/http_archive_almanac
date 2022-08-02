# standardSQL
create temporary function getnestedusage(payload string)
returns array < struct < nested string,
freq int64 >> language js
options(library = "gs://httparchive/lib/css-utils.js") as '''
try {
  var $ = JSON.parse(payload);
  var scss = JSON.parse($['_sass']);
  if (!scss.scss) {
    return [];
  }

  let ret = scss.scss.stats.nested;
  ret.total = sumObject(ret);
  return Object.entries(ret).map(([nested, freq]) => {
    return {nested, freq};
  });
} catch (e) {
  return [];
}
'''
;

select
    client,
    nested,
    count(distinct if(freq > 0, page, null)) as pages,
    sum(freq) as freq,
    sum(sum(freq)) over (partition by client) / 2 as total,
    sum(freq) / (sum(sum(freq)) over (partition by client) / 2) as pct
from
    (
        select
            _table_suffix as client,
            url as page,
            nested.nested,
            sum(nested.freq) as freq
        from `httparchive.pages.2020_08_01_*`, unnest(getnestedusage(payload)) as nested
        group by client, page, nested
    )
group by client, nested
order by pct desc
