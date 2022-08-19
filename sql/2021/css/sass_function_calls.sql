# standardSQL
create temporary function getfunctioncalls(payload string) returns
array < struct < fn string,
freq int64
>> language js as '''
try {
  var $ = JSON.parse(payload);
  var scss = JSON.parse($['_sass']);
  if (!scss.scss) {
    return [];
  }

  return Object.entries(scss.scss.stats.functionCalls).map(([fn, freq]) => {
    return {fn, freq};
  });
} catch (e) {
  return [];
}
'''
;

select *
from
    (
        select
            client,
            fn,
            sum(freq) as freq,
            sum(sum(freq)) over (partition by client) as total,
            sum(freq) / sum(sum(freq)) over (partition by client) as pct
        from
            (
                select _table_suffix as client, fn.fn, fn.freq
                from
                    `httparchive.pages.2021_07_01_*`,
                    unnest(getfunctioncalls(payload)) as fn
            )
        group by client, fn
    )
where freq >= 1000
order by pct desc
