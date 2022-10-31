# standardSQL
# Usage of native lazy loading
create temporary function usesloadinglazy(payload string)
returns boolean
language js
as '''
try {
  const almanac = JSON.parse(payload);

  let found = false;
  for (const node of almanac.images.imgs.nodes) {
    if (node.loading === "lazy") {
      found = true;
      break;
    }
  }

  return found;
} catch (e) {
  return false;
}
'''
;
select
    client,
    countif(total_img > 0) as pages_with_images,

    countif(uses_loading_lazy) as pages_using_loading_attribute,
    countif(uses_loading_lazy)
    / countif(total_img > 0) as pct_pages_using_loading_attribute
from
    (
        select
            _table_suffix as client,
            safe_cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'), '$.images.imgs.total'
                ) as int64
            ) as total_img,
            usesloadinglazy(
                json_extract_scalar(payload, '$._almanac')
            ) as uses_loading_lazy
        from `httparchive.pages.2021_07_01_*`
    )
group by client
