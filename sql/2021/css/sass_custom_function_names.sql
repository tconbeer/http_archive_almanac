# standardSQL
create temporary function getcustomfunctionnames(payload string) returns array
< string
> language js as '''
try {
  var $ = JSON.parse(payload);
  var scss = JSON.parse($['_sass']);
  if (!scss.scss) {
    return [];
  }

  return Object.keys(scss.scss.stats.functions);
} catch (e) {
  return [];
}
'''
;

select
    client,
    sass_custom_function,
    count(distinct url) as pages,
    total_sass,
    count(distinct url) / total_sass as pct_pages
from
    (
        select _table_suffix as client, url, sass_custom_function
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(getcustomfunctionnames(payload)) as sass_custom_function
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
                )
                > 0
            ) as total_sass
        from `httparchive.pages.2021_07_01_*`
        group by client
    ) using (client)
group by client, sass_custom_function, total_sass
order by pct_pages desc
limit 1000
