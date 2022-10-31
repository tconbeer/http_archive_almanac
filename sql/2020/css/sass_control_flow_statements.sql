# standardSQL
create temporary function getstatements(payload string)
returns
    array< struct<statement string, freq int64 >> language js as '''
try {
  var $ = JSON.parse(payload);
  var scss = JSON.parse($['_sass']);
  if (!scss.scss) {
    return [];
  }

  var statements = new Set(['eaches', 'fors', 'ifs', 'whiles']);
  return Object.entries(scss.scss.stats).filter(([prop]) => {
    return statements.has(prop);
  }).map(([statement, obj]) => {
    if (statement == 'ifs') {
      return {statement, freq: obj.length};
    }
    return {statement, freq: Object.values(obj).reduce((total, i) => {
      if (isNaN(i)) {
        return total;
      }
      return total + i;
    }, 0)};
  });
} catch (e) {
  return [];
}
'''
;

select
    client,
    statement,
    count(distinct if(freq > 0, page, null)) as pages,
    sum(freq) as freq,
    sum(sum(freq)) over (partition by client) as total,
    sum(freq) / sum(sum(freq)) over (partition by client) as pct
from
    (
        select
            _table_suffix as client,
            url as page,
            statement.statement,
            sum(statement.freq) as freq
        from
            `httparchive.pages.2020_08_01_*`,
            unnest(getstatements(payload)) as statement
        group by client, page, statement
    )
group by client, statement
order by pct desc
