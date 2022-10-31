create temporary function get_responsive_settings(images_string string)
returns
    array<
        struct<
            sizes bool,
            srcsethaswdescriptors bool,
            sizeswasimplicit bool,
            sizesparseerror bool >> language js
            as '''
let result = [];
try {
const images_ = JSON.parse(images_string);
if (images_ && images_["responsive-images"]) {
    const images = images_["responsive-images"];
    for(const img of images) {
        result.push({
            sizes: img.hasSizes || false,
            srcsetHasWDescriptors: img.srcsetHasWDescriptors || false,
            sizesWasImplicit: img.sizesWasImplicit || false,
            sizesParseError: img.sizesParseError || false
        })
    }
}
} catch (e) {}
return result;
'''
;
select
    client,
    count(0) as images_with_sizes,
    safe_divide(countif(respimg.sizeswasimplicit = true), count(0)) as implicit_pct,
    safe_divide(countif(respimg.sizeswasimplicit = false), count(0)) as explicit_pct,
    safe_divide(countif(respimg.sizesparseerror = true), count(0)) as parseerror_pct,
    safe_divide(
        countif(respimg.srcsethaswdescriptors = true), count(0)
    ) as wdescriptor_pct
from
    (
        select _table_suffix as client, a.url as pageurl, respimg
        from
            `httparchive.pages.2021_07_01_*` as a,
            unnest(
                get_responsive_settings(
                    json_extract_scalar(payload, '$._responsive_images')
                )
            ) as respimg
        where respimg.srcsethaswdescriptors
    )
group by client
