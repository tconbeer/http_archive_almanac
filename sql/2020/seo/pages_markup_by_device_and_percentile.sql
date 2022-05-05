# standardSQL
# percientile data from markup per device
# returns all the data we need from _markup
create temporary function get_markup_info(markup_string string)
returns struct < images_img_total int64,
images_with_alt_present int64,
images_with_alt_blank int64,
images_with_alt_missing int64
> language js
as '''
var result = {
  images_img_total: 0,
  images_with_alt_present: 0,
  images_with_alt_blank: 0,
  images_with_alt_missing: 0
};
try {
    var markup = JSON.parse(markup_string);

    if (Array.isArray(markup) || typeof markup != 'object') return result;

    if (markup.images) {
      if (markup.images.img) {
        var img = markup.images.img;
        result.images_img_total = img.total;

        if (img.alt) {
          result.images_with_alt_present = img.alt.present;
          result.images_with_alt_blank = img.alt.blank;
          result.images_with_alt_missing = img.alt.missing;
        }
      }
    }

} catch (e) {}
return result;
'''
;

select
    percentile,
    client,
    count(distinct url) as total,

    # images per page
    approx_quantiles(markup_info.images_img_total, 1000) [
        offset (percentile * 10)
    ] as img_count,

    # percent of images containg alt text (not blank)
    round(
        approx_quantiles(
            safe_divide(
                markup_info.images_with_alt_present, markup_info.images_img_total
            ),
            1000
        ) [offset (percentile * 10)],
        4
    ) as images_with_alt_present_percent,

    # percent of images containg a blank alt text
    round(
        approx_quantiles(
            safe_divide(
                markup_info.images_with_alt_blank, markup_info.images_img_total
            ),
            1000
        ) [offset (percentile * 10)],
        4
    ) as images_with_alt_blank_percent,

    # percent of images without an alt attribute
    round(
        approx_quantiles(
            safe_divide(
                markup_info.images_with_alt_missing, markup_info.images_img_total
            ),
            1000
        ) [offset (percentile * 10)],
        4
    ) as images_with_alt_missing_percent,

    # number of images containg alt text (not blank)
    approx_quantiles(markup_info.images_with_alt_present, 1000) [
        offset (percentile * 10)
    ] as images_with_alt_present,

    # number of images containg a blank alt text
    approx_quantiles(markup_info.images_with_alt_blank, 1000) [
        offset (percentile * 10)
    ] as images_with_alt_blank,

    # number of images without an alt attribute
    approx_quantiles(markup_info.images_with_alt_missing, 1000) [
        offset (percentile * 10)
    ] as images_with_alt_missing

from
    (
        select
            _table_suffix as client,
            percentile,
            url,
            get_markup_info(json_extract_scalar(payload, '$._markup')) as markup_info
        from
            `httparchive.pages.2020_08_01_*`,
            unnest( [10, 25, 50, 75, 90]) as percentile
    )
group by percentile, client
order by percentile, client
