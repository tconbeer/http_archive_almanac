# standardSQL
CREATE TEMPORARY FUNCTION getMixinUsage(payload STRING) RETURNS
ARRAY<STRUCT<mixin STRING, freq INT64>> LANGUAGE js AS '''
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
''';

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
                    `httparchive.pages.2021_07_01_*`,
                    unnest(getmixinusage(payload)) as mixin
            )
        group by client, mixin
    )
where freq >= 1000
order by pct desc
