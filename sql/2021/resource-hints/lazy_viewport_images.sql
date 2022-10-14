# standardSQL
# Lazy-loaded images within the initial viewport
CREATE TEMPORARY FUNCTION hasLazyLoadedImagesInViewport(payload STRING)
RETURNS STRUCT<isLazy BOOL, inViewport BOOL>
LANGUAGE js AS '''
try {
  var images = JSON.parse(payload);
  if (!Array.isArray(images) || typeof images != "object" || images == null)
    return null;

  if (images.length) {
    const lazyLoadedImages = images.filter(
      (i) => (i.loading || "").toLowerCase() === "lazy"
    );

    if (lazyLoadedImages.length) {
      return {
        isLazy: !!lazyLoadedImages.length,
        inViewport: !!lazyLoadedImages.filter((i) => i.inViewport).length,
      };
    }

    return { isLazy: !!lazyLoadedImages.length };
  }

  return {};
} catch {
  return {};
}
''';

select
    client,
    countif(has_lazy_images_in_viewport.inviewport) as in_viewport,
    countif(has_lazy_images_in_viewport.islazy) as is_lazy,
    countif(has_lazy_images_in_viewport.inviewport)
    / countif(has_lazy_images_in_viewport.islazy) as pct,
    count(0) as total
from
    (
        select
            _table_suffix as client,
            haslazyloadedimagesinviewport(
                json_extract_scalar(payload, '$._Images')
            ) as has_lazy_images_in_viewport
        from `httparchive.pages.2021_07_01_*`
    )
group by client
order by client
