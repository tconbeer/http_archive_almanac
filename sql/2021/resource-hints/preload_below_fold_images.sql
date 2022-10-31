# standardSQL
# Analyze the below the fold (i.e. not in the viewport) images that are preloaded
create temporary function
    preloadednonviewportimages(almanacjsonstr string, imagesjsonstr string)
returns int64
language js
as
    '''
try {
    var almanac = JSON.parse(almanacJsonStr)
    if (Array.isArray(almanac) || typeof almanac != 'object' || almanac == null) return null;

    var images = JSON.parse(imagesJsonStr)
    if (!Array.isArray(images) || typeof images != 'object' || images == null) return null;

    var nodes = almanac["link-nodes"]["nodes"]
    nodes = typeof nodes == 'string' ? JSON.parse(nodes) : nodes

    const imagesNotInVP = images.filter(i => !i.inViewport).map(i => i.url)
    const preloadedImages = new Set(nodes.filter(n => n['as'] === "image" && n['rel'] === 'preload').map(n => n.href))

    let unnecessaryImgPreloads = 0
    for(let i of imagesNotInVP) {
        if(preloadedImages.has(i)) {
            unnecessaryImgPreloads++
        }
    }

    return unnecessaryImgPreloads;
}
catch {
    return null
}
'''
;
with
    image_stats_tb as (
        select
            _table_suffix as client,
            preloadednonviewportimages(
                json_extract_scalar(payload, '$._almanac'),
                json_extract_scalar(payload, '$._Images')
            ) as num_non_viewport_preload_images
        from `httparchive.pages.2021_07_01_*`
    )

select
    client,
    num_non_viewport_preload_images,
    count(0) as pages,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from image_stats_tb
group by client, num_non_viewport_preload_images
