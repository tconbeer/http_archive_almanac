# standardSQL
# percientile data from markup per device
# returns all the data we need from _markup
CREATE TEMPORARY FUNCTION get_markup_info(markup_string STRING)
RETURNS STRUCT<
  favicon BOOL,
  app_id_present BOOL,
  amp_rel_amphtml_present BOOL,
  noscripts_count INT64,
  noscripts_iframe_googletagmanager_count INT64,
  svg_element_total INT64,
  svg_img_total INT64,
  svg_object_total INT64,
  svg_embed_total INT64,
  svg_iframe_total INT64,
  svg_total INT64,
  buttons_total INT64,
  buttons_with_type INT64,
  contains_audios_with_autoplay BOOL,
  contains_audios_without_autoplay BOOL,
  inputs_types_image_total INT64,
  inputs_types_button_total INT64,
  inputs_types_submit_total INT64,
  dirs_html_dir STRING,
  dirs_body_nodes_dir_total INT64
> LANGUAGE js AS '''
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
        //.filter(([key, value]) => key == "" || key == "autoplay") // should check, but lets just include all values
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
''';

select
    percentile,
    client,
    count(distinct url) as total,

    # comments
    approx_quantiles(markup_info.noscripts_count, 1000)[
        offset(percentile * 10)
    ] as noscripts_count_m212,
    approx_quantiles(markup_info.noscripts_iframe_googletagmanager_count, 1000)[
        offset(percentile * 10)
    ] as noscripts_iframe_googletagmanager_count,

    # svg
    approx_quantiles(markup_info.svg_element_total, 1000)[
        offset(percentile * 10)
    ] as svg_element_count_m224,
    approx_quantiles(markup_info.svg_img_total, 1000)[
        offset(percentile * 10)
    ] as svg_img_count_m226,
    approx_quantiles(markup_info.svg_object_total, 1000)[
        offset(percentile * 10)
    ] as svg_object_count_m228,
    approx_quantiles(markup_info.svg_embed_total, 1000)[
        offset(percentile * 10)
    ] as svg_embed_count_m230,
    approx_quantiles(markup_info.svg_iframe_total, 1000)[
        offset(percentile * 10)
    ] as svg_iframe_count_m232,
    approx_quantiles(markup_info.svg_total, 1000)[offset(percentile * 10)] as svg_count,

    # buttons
    approx_quantiles(markup_info.buttons_total, 1000)[
        offset(percentile * 10)
    ] as buttons_count_m301,

    # inputs
    approx_quantiles(markup_info.inputs_types_image_total, 1000)[
        offset(percentile * 10)
    ] as inputs_types_image_count_m305,
    approx_quantiles(markup_info.inputs_types_button_total, 1000)[
        offset(percentile * 10)
    ] as inputs_types_button_count_m306,
    approx_quantiles(markup_info.inputs_types_submit_total, 1000)[
        offset(percentile * 10)
    ] as inputs_types_submit_count_m307

from
    (
        select
            _table_suffix as client,
            percentile,
            url,
            get_markup_info(json_extract_scalar(payload, '$._markup')) as markup_info
        from
            `httparchive.pages.2020_08_01_*`,
            unnest([10, 25, 50, 75, 90, 95, 96, 97, 98, 99]) as percentile
    )
group by percentile, client
order by percentile, client
