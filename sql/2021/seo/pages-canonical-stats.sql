# standardSQL
# page canonical metrics by device
# Note: Contains redundant stats to seo-stats.sql in order to start better segmenting
# metrics away from monolithic queries.
# JS parsing of payload
create temporary function getcanonicalmetrics(payload string)
returns
    struct<
        has_wpt_bodies bool,
        has_canonicals bool,
        has_self_canonical bool,
        is_canonicalized bool,
        has_http_canonical bool,
        has_rendered_canonical bool,
        has_raw_canonical bool,
        has_canonical_mismatch bool,
        rendering_changed_canonical bool,
        http_header_changed_canonical bool,
        has_relative_canonical bool,
        has_absolute_canonical bool,
        js_error bool
    >
language js
as
    '''

var result = {has_wpt_bodies: true,
              has_canonicals: false,
              has_self_canonical: false,
              is_canonicalized: false,
              has_http_canonical: false,
              has_rendered_canonical: false,
              has_raw_canonical: false,
              canonical_missmatch: false,
              rendering_changed_canonical: false,
              http_header_changed_canonical: false,
              has_relative_canonical: false,
              has_absolute_canonical: false,
              js_error: false};

  function compareStringArrays(array1, array2) {
      if (!array1 && !array2) return true; // both missing
      if (!Array.isArray(array1) || !Array.isArray(array2)) return false; //not comparing arays so can't report comparision
      if (!array1 && array2.length > 0) return false;
      if (!array2 && array1.length > 0) return false;
      if (array1.length != array2.length) return false;

      array1 = array1.slice();
      array1.sort();
      array2 = array2.slice();
      array2.sort();
      for (var i = 0; i < array1.length; i++) {
          if (array1[i] != array2[i]) {
              return false;
          }
      }
      return true;
  }


try {

  var $ = JSON.parse(payload);
  var wpt_bodies  = JSON.parse($._wpt_bodies);

  if (!wpt_bodies){
      result.has_wpt_bodies = false;
      return result;
  }

  var canonicals = wpt_bodies.canonicals;

  if (canonicals) {

    if (canonicals.canonicals && canonicals.canonicals.length) {
      result.has_canonicals = canonicals.canonicals.length > 0;
    }
    if (canonicals.self_canonical) {
      result.has_self_canonical = canonicals.self_canonical;
    }
    if (canonicals.other_canonical) {
      result.is_canonicalized = canonicals.other_canonical;
    }
    if (canonicals.http_header_link_canoncials) {
      result.has_http_canonical = canonicals.http_header_link_canoncials.length > 0;
    }
    if (canonicals.rendered && canonicals.rendered.html_link_canoncials) {
      result.has_rendered_canonical = canonicals.rendered.html_link_canoncials.length > 0;
    }
    if (canonicals.raw && canonicals.raw.html_link_canoncials) {
      result.has_raw_canonical = canonicals.raw.html_link_canoncials.length > 0;
    }
    if (canonicals.canonical_missmatch) {
      result.has_canonical_mismatch = canonicals.canonical_missmatch;
    }
    if (canonicals.raw && canonicals.rendered) {
      result.rendering_changed_canonical = !compareStringArrays(canonicals.raw.html_link_canoncials, canonicals.rendered.html_link_canoncials);
    }
    if (canonicals.raw && canonicals.http_header_link_canoncials && canonicals.http_header_link_canoncials.length > 0) {
      result.http_header_changed_canonical = !compareStringArrays(canonicals.raw.html_link_canoncials, canonicals.http_header_link_canoncials);
    }

    if (result.has_canonicals){
      result.has_relative_canonical  = [].map.call(canonicals.canonicals, (e) => {return e.startsWith('/')}).indexOf(true) > -1;
      result.has_absolute_canonical  = [].map.call(canonicals.canonicals, (e) => {return e.startsWith('http')}).indexOf(true) > -1;
    }

  }

  return result;

} catch (e) {
  result.js_error = true;
  return result;
}
'''
;



select
    client,
    count(0) as total,
    canonical_metrics.js_error as js_error,

    # Pages with canonical
    safe_divide(
        countif(canonical_metrics.has_canonicals), count(0)
    ) as pct_has_canonical,

    # Pages with self-canonical
    safe_divide(
        countif(canonical_metrics.has_self_canonical), count(0)
    ) as pct_has_self_canonical,

    # Pages canonicalized
    safe_divide(
        countif(canonical_metrics.is_canonicalized), count(0)
    ) as pct_is_canonicalized,

    # Pages with canonical in HTTP header
    safe_divide(
        countif(canonical_metrics.has_http_canonical), count(0)
    ) as pct_http_canonical,

    # Pages with canonical in raw html
    safe_divide(
        countif(canonical_metrics.has_raw_canonical), count(0)
    ) as pct_has_raw_canonical,

    # Pages with canonical in rendered html
    safe_divide(
        countif(canonical_metrics.has_rendered_canonical), count(0)
    ) as pct_has_rendered_canonical,

    # Pages with canonical in rendered but not raw html
    safe_divide(
        countif(
            canonical_metrics.has_rendered_canonical
            and not canonical_metrics.has_raw_canonical
        ),
        count(0)
    ) as pct_has_rendered_but_not_raw_canonical,

    # Pages with canonical mismatch
    safe_divide(
        countif(canonical_metrics.has_canonical_mismatch), count(0)
    ) as pct_has_canonical_mismatch,

    # Pages with canonical conflict between raw and rendered
    safe_divide(
        countif(canonical_metrics.rendering_changed_canonical), count(0)
    ) as pct_has_conflict_rendering_changed_canonical,

    # Pages with canonical conflict between raw and http header
    safe_divide(
        countif(canonical_metrics.http_header_changed_canonical), count(0)
    ) as pct_has_conflict_http_header_changed_canonical,

    # Pages with canonical conflict between raw and http header
    safe_divide(
        countif(
            canonical_metrics.http_header_changed_canonical
            or canonical_metrics.rendering_changed_canonical
        ),
        count(0)
    ) as pct_has_conflict_http_header_or_rendering_changed_canonical,

    # Pages with canonicals that are absolute
    safe_divide(
        countif(canonical_metrics.has_absolute_canonical),
        countif(canonical_metrics.has_canonicals)
    ) as pct_canonicals_absolute,

    # Pages with canonicals that are relative
    safe_divide(
        countif(canonical_metrics.has_relative_canonical),
        countif(canonical_metrics.has_canonicals)
    ) as pct_canonicals_relative

from
    (
        select
            _table_suffix as client, getcanonicalmetrics(payload) as canonical_metrics
        from `httparchive.pages.2021_07_01_*`
    )

-- Only reporting where wpt_bodies sucessfully extracted. ~20/100,000 pages missing
-- wpt_bodies.
where canonical_metrics.has_wpt_bodies
group by client, js_error
