# standardSQL
create temporary function getmixinnames(payload string) returns array
< string
> language js
as '''
try {
  var $ = JSON.parse(payload);
  var scss = JSON.parse($['_sass']);
  if (!scss.scss) {
    return [];
  }

  return Object.keys(scss.scss.stats.mixins);
} catch (e) {
  return [];
}
'''
;

select
    client,
    mixin,
    count(distinct url) as pages,
    total_sass,
    count(distinct url) / total_sass as pct
from
    (
        select _table_suffix as client, url, mixin
        from `httparchive.pages.2020_08_01_*`, unnest(getmixinnames(payload)) as mixin
    )
join
    (
        select
            _table_suffix as client,
            countif(
                safe_cast(
                    json_extract_scalar(
                        json_extract_scalar(payload, '$._sass'), '$.scss.size'
                    ) as int64
                ) > 0
            ) as total_sass
        from `httparchive.pages.2020_08_01_*`
        group by client
    )
    using
    (client)
group by client, mixin, total_sass
order by pct desc
limit 1000
