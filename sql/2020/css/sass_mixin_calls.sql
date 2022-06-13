# standardSQL
create temporary function getmixinusage(payload string) returns
array < struct < mixin string,
freq int64
>> language js
as '''
try {
  var $ = JSON.parse(payload);
  var scss = JSON.parse($['_sass']);
  if (!scss.scss) {
    return [];
  }

  return Object.entries(scss.scss.stats.mixins).map(([mixin, {calls}]) => {
    return {mixin, freq: calls};
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
            mixin,
            sum(freq) as freq,
            sum(sum(freq)) over (partition by client) as total,
            sum(freq) / sum(sum(freq)) over (partition by client) as pct
        from
            (
                select _table_suffix as client, mixin.mixin, mixin.freq
                from
                    `httparchive.pages.2020_08_01_*`,
                    unnest(getmixinusage(payload)) as mixin
            )
        group by client, mixin
    )
where freq >= 1000
order by pct desc
