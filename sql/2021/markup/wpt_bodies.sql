# standardSQL
# page wpt_bodies metrics grouped by device
# returns all the data we need from _wpt_bodies
CREATE TEMPORARY FUNCTION get_wpt_bodies_info(wpt_bodies_string STRING)
RETURNS STRUCT<
  comment_count INT64,
  conditional_comment_count INT64,
  head_size INT64,
  no_h1 BOOL,
  target_blank_total INT64,
  target_blank_noopener_noreferrer_total INT64,
  target_blank_noopener_total INT64,
  target_blank_noreferrer_total INT64,
  target_blank_neither_total INT64
> LANGUAGE js AS '''
var result = {};
try {
    var wpt_bodies = JSON.parse(wpt_bodies_string);

    if (Array.isArray(wpt_bodies) || typeof wpt_bodies != 'object') return result;

    if (wpt_bodies.raw_html) {
      result.comment_count = wpt_bodies.raw_html.comment_count;
      result.conditional_comment_count = wpt_bodies.raw_html.conditional_comment_count;
      result.head_size = wpt_bodies.raw_html.head_size;
    }

    result.no_h1 = !wpt_bodies.headings || !wpt_bodies.headings.rendered || !wpt_bodies.headings.rendered.h1 || !wpt_bodies.headings.rendered.h1.total || wpt_bodies.headings.rendered.h1.total === 0;

    if (wpt_bodies.anchors && wpt_bodies.anchors.rendered && wpt_bodies.anchors.rendered.target_blank) {
      result.target_blank_total = wpt_bodies.anchors.rendered.target_blank.total;
      result.target_blank_noopener_noreferrer_total = wpt_bodies.anchors.rendered.target_blank.noopener_noreferrer;
      result.target_blank_noopener_total = wpt_bodies.anchors.rendered.target_blank.noopener;
      result.target_blank_noreferrer_total = wpt_bodies.anchors.rendered.target_blank.noreferrer;
      result.target_blank_neither_total = wpt_bodies.anchors.rendered.target_blank.neither;
    }
} catch (e) {}
return result;
''';

select
    client,
    count(0) as total,

    # % of pages with comments
    countif(wpt_bodies_info.comment_count > 0) / count(0) as pct_contains_comment,

    # % of pages with conditional comments
    countif(wpt_bodies_info.conditional_comment_count > 0)
    / count(0) as pct_contains_conditional_comment,

    # pages without an h1
    countif(wpt_bodies_info.no_h1) / count(0) as pct_no_h1,

    # pages with all target _banks including rel="noopener noreferrer"
    countif(
        wpt_bodies_info.target_blank_total is null
        or wpt_bodies_info.target_blank_total
        = wpt_bodies_info.target_blank_noopener_noreferrer_total
    )
    / count(0) as pct_always_target_blank_noopener_noreferrer,

    # pages with some target _banks not using rel="noopener noreferrer"
    countif(
        wpt_bodies_info.target_blank_total
        > wpt_bodies_info.target_blank_noopener_noreferrer_total
    )
    / count(0) as pct_some_target_blank_without_noopener_noreferrer,

    countif(wpt_bodies_info.target_blank_total > 0) / count(0) as pct_has_target_blank,
    countif(wpt_bodies_info.target_blank_noopener_noreferrer_total > 0)
    / count(0) as pct_has_target_blank_noopener_noreferrer,
    countif(wpt_bodies_info.target_blank_noopener_total > 0)
    / count(0) as pct_has_target_blank_noopener,
    countif(wpt_bodies_info.target_blank_noreferrer_total > 0)
    / count(0) as pct_has_target_blank_noreferrer,
    countif(wpt_bodies_info.target_blank_neither_total > 0)
    / count(0) as pct_has_target_blank_neither

from
    (
        select
            _table_suffix as client,
            get_wpt_bodies_info(
                json_extract_scalar(payload, '$._wpt_bodies')
            ) as wpt_bodies_info
        from `httparchive.pages.2021_07_01_*`
    )
group by client
