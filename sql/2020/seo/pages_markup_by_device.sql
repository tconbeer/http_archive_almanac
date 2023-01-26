# standardSQL
# pages markup metrics grouped by device
# helper to create percent fields
create temp function as_percent(freq float64, total float64)
returns float64
as (round(safe_divide(freq, total), 4))
;

# returns all the data we need from _markup
create temporary function get_markup_info(markup_string string)
returns
    struct<
        images_img_total int64,
        images_alt_missing_total int64,
        images_alt_blank_total int64,
        images_alt_present_total int64,

        has_html_amp_attribute bool,
        has_rel_amphtml_tag bool,
        has_html_amp_emoji_attribute bool
    >
language js
as
    '''
var result = {
  images_img_total: 0,
  images_alt_missing_total: 0,
  images_alt_blank_total: 0,
  images_alt_present_total: 0,
  has_html_amp_attribute: false,
  has_rel_amphtml_tag: false,
  has_html_amp_emoji_attribute: false
};
try {
    var markup = JSON.parse(markup_string);

    if (Array.isArray(markup) || typeof markup != 'object') return result;

    if (markup.images) {
      if (markup.images.img) {
        var img = markup.images.img;
        result.images_img_total = img.total;

        if (img.alt) {
          var alt = img.alt;
            result.images_alt_missing_total = alt.missing;
            result.images_alt_blank_total = alt.blank;
            result.images_alt_present_total = alt.present; // present does not include blank
        }
      }
    }

    if (markup.amp) {
      result.has_html_amp_attribute = markup.amp.html_amp_attribute_present;
      result.has_html_amp_emoji_attribute = markup.amp.html_amp_emoji_attribute_present;
      result.has_rel_amphtml_tag = markup.amp.rel_amphtml;
    }
} catch (e) {}
return result;
'''
;

select
    client,
    count(0) as total,

    # Pages with img
    as_percent(countif(markup_info.images_img_total > 0), count(0)) as pct_has_img,

    # percent pages with an img alt
    sum(markup_info.images_img_total) as total_img,
    sum(markup_info.images_alt_present_total) as total_img_alt_present,
    sum(markup_info.images_alt_blank_total) as total_img_alt_blank,
    sum(markup_info.images_alt_missing_total) as total_img_alt_missing,
    as_percent(
        sum(markup_info.images_alt_missing_total), sum(markup_info.images_img_total)
    ) as pct_images_with_img_alt_missing,
    as_percent(
        sum(markup_info.images_alt_present_total), sum(markup_info.images_img_total)
    ) as pct_images_with_img_alt_present,  # present does not include blank
    as_percent(
        sum(markup_info.images_alt_blank_total), sum(markup_info.images_img_total)
    ) as pct_images_with_img_alt_blank,
    as_percent(
        sum(markup_info.images_alt_blank_total)
        + sum(markup_info.images_alt_present_total),
        sum(markup_info.images_img_total)
    ) as pct_images_with_img_alt_blank_or_present,

    # Pages with <html amp> tag
    countif(markup_info.has_html_amp_attribute) as has_html_amp_attribute,
    countif(markup_info.has_html_amp_emoji_attribute) as has_html_amp_emoji_attribute,
    as_percent(
        countif(markup_info.has_html_amp_attribute), count(0)
    ) as pct_has_html_amp_attribute,
    as_percent(
        countif(markup_info.has_html_amp_emoji_attribute), count(0)
    ) as pct_has_html_amp_emoji_attribute,
    as_percent(
        countif(
            markup_info.has_html_amp_emoji_attribute
            or markup_info.has_html_amp_attribute
        ),
        count(0)
    ) as pct_has_html_amp_or_emoji_attribute,

    # Pages with rel=amphtml
    as_percent(
        countif(markup_info.has_rel_amphtml_tag), count(0)
    ) as pct_has_rel_amphtml_tag

from
    (
        select
            _table_suffix as client,
            get_markup_info(json_extract_scalar(payload, '$._markup')) as markup_info
        from `httparchive.pages.2020_08_01_*`
    )
group by client
