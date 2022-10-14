# standardSQL
# pages almanac metrics grouped by device
# real run estimated at $4.08 and took 48 seconds
# to speed things up there is only one js function per custom metric property. It
# returns a STRUCT with all the data needed
# current test gathers 3 bits of incormation from the custom petric properties
# I tried to do a single js function processing the whole payload but it was very slow
# (50 sec) because of parsing the full payload in js
# this uses JSON_EXTRACT_SCALAR to first get the custom metrics json string, and only
# passes those into the js functions
# Estimate about twice the speed of the original code. But should scale up far better
# as the custom metrics are only parsed once.
# returns all the data we need from _almanac
CREATE TEMPORARY FUNCTION get_almanac_info(almanac_string STRING)
RETURNS STRUCT<
  scripts_total INT64,
  none_jsonld_scripts_total INT64,
  src_scripts_total INT64,
  inline_scripts_total INT64,
  good_heading_sequence BOOL,
  contains_videos_with_autoplay BOOL,
  contains_videos_without_autoplay BOOL,
  html_node_lang STRING
> LANGUAGE js AS '''
var result = {};
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return result;

    if (almanac.scripts) {
      result.scripts_total = almanac.scripts.total;
      if (almanac.scripts.nodes) {
        result.none_jsonld_scripts_total = almanac.scripts.nodes.filter(n => !n.type || n.type.trim().toLowerCase() !== 'application/ld+json').length;
        result.src_scripts_total = almanac.scripts.nodes.filter(n => n.src && n.src.trim().length > 0).length;

        result.inline_scripts_total = result.none_jsonld_scripts_total - result.src_scripts_total;
      }
    }

    if (almanac.headings_order) {
      var good = true;
      var previousLevel = 0;
      almanac.headings_order.forEach(level =>  {
          if (previousLevel + 1 < level) { // jumped a level
            good = false;
          }
          previousLevel = level;
      });
      result.good_heading_sequence = good;
    }

    if (almanac.videos) {
      var autoplay_count = almanac.videos.nodes.filter(n => n.autoplay == "" || n.autoplay).length; // valid values are blank or autoplay. Im just checking it exists...

      result.contains_videos_with_autoplay = autoplay_count > 0;
      result.contains_videos_without_autoplay = almanac.videos.total > autoplay_count;
    }

    if (almanac.html_node) {
      result.html_node_lang = almanac.html_node.lang;
    }

} catch (e) {}
return result;
''';

select
    client,
    count(0) as total,

    # has scripts that are not jsonld ones. i.e. has a none jsonld script.
    countif(almanac_info.none_jsonld_scripts_total > 0)
    / count(0) as pct_contains_none_jsonld_scripts,

    # has inline scripts
    countif(almanac_info.inline_scripts_total > 0)
    / count(0) as pct_contains_inline_scripts,

    # has src scripts
    countif(almanac_info.src_scripts_total > 0) / count(0) as pct_contains_src_scripts,

    # has no scripts
    countif(almanac_info.scripts_total = 0) / count(0) as pct_contains_no_scripts,

    # Does the heading logical sequence make any sense
    countif(almanac_info.good_heading_sequence) / count(0) as pct_good_heading_sequence,

    # pages with autoplaying video elements
    countif(almanac_info.contains_videos_with_autoplay)
    / count(0) as pct_contains_videos_with_autoplay,

    # pages without autoplaying video elements
    countif(almanac_info.contains_videos_without_autoplay)
    / count(0) as pct_contains_videos_without_autoplay,

    # pages with no html lang attribute
    countif(
        almanac_info.html_node_lang is null or length(almanac_info.html_node_lang) = 0
    )
    / count(0) as pct_no_html_lang

from
    (
        select
            _table_suffix as client,
            get_almanac_info(json_extract_scalar(payload, '$._almanac')) as almanac_info
        from `httparchive.pages.2021_07_01_*`
    )
group by client
