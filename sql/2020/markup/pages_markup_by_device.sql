# standardSQL
# pages markup metrics grouped by device
# helper to create percent fields
create temp function as_percent(freq float64, total float64) returns float64 as (
    round(safe_divide(freq, total), 4)
)
;

# returns all the data we need from _markup
create temporary function get_markup_info(markup_string string)
returns struct < favicon bool,
app_id_present bool,
amp_rel_amphtml_present bool,
noscripts_count int64,
noscripts_iframe_googletagmanager_count int64,
svg_element_total int64,
svg_img_total int64,
svg_object_total int64,
svg_embed_total int64,
svg_iframe_total int64,
svg_total int64,
buttons_total int64,
buttons_with_type int64,
contains_audios_with_autoplay bool,
contains_audios_without_autoplay bool,
inputs_types_image_total int64,
inputs_types_button_total int64,
inputs_types_submit_total int64,
dirs_html_dir string,
dirs_body_nodes_dir_total int64
> language js
as '''
var result = {};
try {
    var markup = JSON.parse(markup_string);

    if (Array.isArray(markup) || typeof markup != 'object') return result;

    result.favicon = !!markup.favicon;

    if (markup.app) {
      result.app_id_present = !!markup.app.app_id_present;
    }

    if (markup.amp) {
      result.amp_rel_amphtml_present = !!markup.amp.rel_amphtml;
    }

    if (markup.noscripts) {
      result.noscripts_count = markup.noscripts.total;
      result.noscripts_iframe_googletagmanager_count = markup.noscripts.iframe_googletagmanager_count;
    }

    if (markup.svgs) {
      result.svg_element_total = markup.svgs.svg_element_total;
      result.svg_img_total = markup.svgs.svg_img_total;
      result.svg_object_total = markup.svgs.svg_object_total;
      result.svg_embed_total = markup.svgs.svg_embed_total;
      result.svg_iframe_total = markup.svgs.svg_iframe_total;
      result.svg_total = markup.svgs.svg_total;
    }

    if (markup.buttons) {
      result.buttons_total = markup.buttons.total;

      result.buttons_with_type = Object.values(markup.buttons.types).reduce((total, freq) => total + freq, 0);
    }

    if (markup.audios) {

      var autoplay_count = Object.entries(markup.audios.autoplay)
        // .filter(([key, value]) => key == "" || key == "autoplay") // should check, but lets just include all values
        .reduce((total, [key, value]) => total + value, 0);

      result.contains_audios_with_autoplay = autoplay_count > 0;
      result.contains_audios_without_autoplay = markup.audios.total > autoplay_count;
    }

    if (markup.inputs) {
      result.inputs_types_image_total = Object.entries(markup.inputs.types)
        .filter(([key, value]) => key.trim().toLowerCase() == "image")
        .reduce((total, [key, value]) => total + value, 0);

      result.inputs_types_button_total = Object.entries(markup.inputs.types)
        .filter(([key, value]) => key.trim().toLowerCase() == "button")
        .reduce((total, [key, value]) => total + value, 0);

      result.inputs_types_submit_total = Object.entries(markup.inputs.types)
        .filter(([key, value]) => key.trim().toLowerCase() == "submit")
        .reduce((total, [key, value]) => total + value, 0);
    }

    if (markup.dirs) {
      if (markup.dirs.html_dir) {
        result.dirs_html_dir = markup.dirs.html_dir.trim().toLowerCase();
      }

      if (markup.dirs.body_nodes_dir) {
        result.dirs_body_nodes_dir_total = markup.dirs.body_nodes_dir.total;
      }
    }

} catch (e) {}
return result;
'''
;

select
    client,
    count(0) as total,

    # pages with a favicon
    as_percent(countif(markup_info.favicon), count(0)) as pct_favicon_m218,

    # pages identified as an app M403
    as_percent(
        countif(markup_info.app_id_present), count(0)
    ) as pct_app_id_present_m403,

    # pages with a link rel="amphtml" M430
    as_percent(
        countif(markup_info.amp_rel_amphtml_present), count(0)
    ) as pct_amp_rel_amphtml_present_m430,

    # pages with a noscript tag
    as_percent(
        countif(markup_info.noscripts_count > 0), count(0)
    ) as pct_noscripts_m211,

    # pages with a noscript gtm tag
    as_percent(
        countif(markup_info.noscripts_iframe_googletagmanager_count > 0), count(0)
    ) as pct_noscripts_gtm_tag_m213,

    # pages with an svg element
    as_percent(
        countif(markup_info.svg_element_total > 0), count(0)
    ) as pct_svg_element_m223,

    # pages with an svg img
    as_percent(
        countif(markup_info.svg_img_total > 0), count(0)
    ) as pct_svg_svg_img_m225,

    # pages with an svg object
    as_percent(
        countif(markup_info.svg_object_total > 0), count(0)
    ) as pct_svg_object_m227,

    # pages with an svg embed
    as_percent(
        countif(markup_info.svg_embed_total > 0), count(0)
    ) as pct_svg_embed_m229,

    # pages with an svg iframe
    as_percent(
        countif(markup_info.svg_iframe_total > 0), count(0)
    ) as pct_svg_iframe_m231,

    # pages with an svg
    as_percent(countif(markup_info.svg_total > 0), count(0)) as pct_svg__m233,

    # pages with a button
    as_percent(countif(markup_info.buttons_total > 0), count(0)) as pct_buttons_m302,

    # pages with a button without a type
    as_percent(
        countif(markup_info.buttons_total > markup_info.buttons_with_type), count(0)
    ) as pct_buttons_without_type_m303,

    # pages with autoplaying audio elements M312
    as_percent(
        countif(markup_info.contains_audios_with_autoplay), count(0)
    ) as pct_contains_audios_with_autoplay_m312,

    # pages with non autoplaying audio elements M313
    as_percent(
        countif(markup_info.contains_audios_without_autoplay), count(0)
    ) as pct_contains_audios_without_autoplay_m313,

    # pages with html dir set M410
    as_percent(
        countif(length(markup_info.dirs_html_dir) > 0), count(0)
    ) as pct_html_dir_set_m410,

    # pages with html dir set to ltr M411
    as_percent(
        countif(markup_info.dirs_html_dir = 'ltr'), count(0)
    ) as pct_html_dir_ltr_m411,

    # pages with html dir set to rtl M412
    as_percent(
        countif(markup_info.dirs_html_dir = 'rtl'), count(0)
    ) as pct_html_dir_rtl_m412,

    # pages with html dir set to auto M413
    as_percent(
        countif(markup_info.dirs_html_dir = 'auto'), count(0)
    ) as pct_html_dir_auto_m413,

    # pages with dir on other elements M414
    as_percent(
        countif(markup_info.dirs_body_nodes_dir_total > 0), count(0)
    ) as pct_body_nodes_dir_set_m414

from
    (
        select
            _table_suffix as client,
            get_markup_info(json_extract_scalar(payload, '$._markup')) as markup_info
        from `httparchive.pages.2020_08_01_*`
    )
group by client
