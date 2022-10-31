# standardSQL
# page wpt_bodies metrics grouped by device
# helper to create percent fields
create temp function as_percent(freq float64, total float64)
returns float64
as (round(safe_divide(freq, total), 4))
;

# returns all the data we need from _wpt_bodies
create temporary function get_wpt_bodies_info(wpt_bodies_string string)
returns
    struct<

        # tags
        n_titles int64,
        title_words int64,
        n_meta_descriptions int64,
        n_h1 int64,
        n_h2 int64,
        n_h3 int64,
        n_h4 int64,
        n_non_empty_h1 int64,
        n_non_empty_h2 int64,
        n_non_empty_h3 int64,
        n_non_empty_h4 int64,
        has_same_h1_title bool,

        # robots
        robots_has_robots_meta_tag bool,
        robots_has_x_robots_tag bool,
        rendering_changed_robots_meta_tag bool,

        # canonical
        has_canonicals bool,
        has_self_canonical bool,
        is_canonicalized bool,
        has_http_canonical bool,
        has_rendered_canonical bool,
        has_raw_canonical bool,
        has_canonical_mismatch bool,
        rendering_changed_canonical bool,
        http_header_changed_canonical bool,

        # hreflang
        rendering_changed_hreflang bool,
        has_hreflang bool,
        has_http_hreflang bool,
        has_rendered_hreflang bool,
        has_raw_hreflang bool,

        # structured data
        has_raw_jsonld_or_microdata bool,
        has_rendered_jsonld_or_microdata bool,
        rendering_changes_structured_data bool,

        # meta robots
        rendered_otherbot_status_index bool,
        rendered_otherbot_status_follow bool,
        rendered_otherbot_noarchive bool,
        rendered_otherbot_nosnippet bool,
        rendered_otherbot_unavailable_after bool,
        rendered_otherbot_max_snippet bool,
        rendered_otherbot_max_image_preview bool,
        rendered_otherbot_max_video_preview bool,
        rendered_otherbot_notranslate bool,
        rendered_otherbot_noimageindex bool,
        rendered_otherbot_nocache bool,

        rendered_googlebot_status_index bool,
        rendered_googlebot_status_follow bool,
        rendered_googlebot_noarchive bool,
        rendered_googlebot_nosnippet bool,
        rendered_googlebot_unavailable_after bool,
        rendered_googlebot_max_snippet bool,
        rendered_googlebot_max_image_preview bool,
        rendered_googlebot_max_video_preview bool,
        rendered_googlebot_notranslate bool,
        rendered_googlebot_noimageindex bool,
        rendered_googlebot_nocache bool,

        rendered_googlebot_news_status_index bool,
        rendered_googlebot_news_status_follow bool,
        rendered_googlebot_news_noarchive bool,
        rendered_googlebot_news_nosnippet bool,
        rendered_googlebot_news_unavailable_after bool,
        rendered_googlebot_news_max_snippet bool,
        rendered_googlebot_news_max_image_preview bool,
        rendered_googlebot_news_max_video_preview bool,
        rendered_googlebot_news_notranslate bool,
        rendered_googlebot_news_noimageindex bool,
        rendered_googlebot_news_nocache bool
    >
language js
as
    '''
var result = {};
try {
  var wpt_bodies = JSON.parse(wpt_bodies_string);

  if (Array.isArray(wpt_bodies) || typeof wpt_bodies != 'object') return result;

  // checks if two string arrays contain the same strings
  function compareStringArrays(array1, array2) {
      if (!array1 && !array2) return true; // both missing
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

  var title = wpt_bodies.title;
  if (title) {
    if (title.rendered) {
      var title_rendered = title.rendered;
      //Number of words in the title tag
      if (title_rendered.primary) {
        result.title_words = title_rendered.primary.words;
      }

      //If the webpage has a title
      result.n_titles = title_rendered.total
    }
  }

  var meta_description = wpt_bodies.meta_description;
  if (meta_description) {

    if (meta_description.rendered) {
      //If the webpage has a meta description
      result.n_meta_descriptions = meta_description.rendered.total;
    }
  }

  var headings = wpt_bodies.headings;
  if (headings) {
    var headings_rendered = headings.rendered;
    if (headings_rendered) {

      //If the webpage has h1
      result.n_h1 = headings_rendered.h1.total;

      //If the webpage has h2
      result.n_h2 = headings_rendered.h2.total;

      //If the webpage has h3
      result.n_h3 = headings_rendered.h3.total;

      //If the webpage has h4
      result.n_h4 = headings_rendered.h4.total;

      //If the webpage has a non empty h1
      result.n_non_empty_h1 = headings_rendered.h1.non_empty_total;

      //If the webpage has a non empty h2
      result.n_non_empty_h2 = headings_rendered.h2.non_empty_total;

      //If the webpage has a non empty h3
      result.n_non_empty_h3 = headings_rendered.h3.non_empty_total;

      //If the webpage has a non empty h4
      result.n_non_empty_h4 = headings_rendered.h4.non_empty_total;


      //If h1 and title tag are the same
      result.has_same_h1_title = headings_rendered.primary.matches_title;
    }
  }

  var robots = wpt_bodies.robots;
  if (robots) {
    result.robots_has_robots_meta_tag = robots.has_robots_meta_tag;
    result.robots_has_x_robots_tag = robots.has_x_robots_tag;

    // added to rendered
    // has_rendered_robots_meta_tag ???
    // added to raw
    // raw and rendered are different

    //rendering_changed_robots_meta_tag
    // if the raw and rendered data are different.
    if (robots.raw && robots.rendered) {
      var rendered = robots.rendered;
      var raw = robots.raw;
      if (
        rendered.otherbot.status_index !== raw.otherbot.status_index ||
        rendered.otherbot.status_follow !== raw.otherbot.status_follow ||
        rendered.googlebot.status_index !== raw.googlebot.status_index ||
        rendered.googlebot.status_follow !== raw.googlebot.status_follow ||
        rendered.googlebot_news.status_index !== raw.googlebot_news.status_index ||
        rendered.googlebot_news.status_follow !== raw.googlebot_news.status_follow ||
        JSON.stringify(rendered.google) !== JSON.stringify(raw.google)
      )
      {
        result.rendering_changed_robots_meta_tag = true;
      }
      else
      {
        result.rendering_changed_robots_meta_tag = false;
      }

      result.rendered_otherbot_status_index = rendered.otherbot.status_index;
      result.rendered_otherbot_status_follow = rendered.otherbot.status_follow;
      result.rendered_otherbot_noarchive = rendered.otherbot.noarchive === true;
      result.rendered_otherbot_nosnippet = rendered.otherbot.nosnippet === true;
      result.rendered_otherbot_unavailable_after = rendered.otherbot.unavailable_after === true;
      result.rendered_otherbot_max_snippet = rendered.otherbot.max_snippet === true;
      result.rendered_otherbot_max_image_preview = rendered.otherbot.max_image_preview === true;
      result.rendered_otherbot_max_video_preview = rendered.otherbot.max_video_preview === true;
      result.rendered_otherbot_notranslate = rendered.otherbot.notranslate === true;
      result.rendered_otherbot_noimageindex = rendered.otherbot.noimageindex === true;
      result.rendered_otherbot_nocache = rendered.otherbot.nocache === true;

      result.rendered_googlebot_status_index = rendered.googlebot.status_index;
      result.rendered_googlebot_status_follow = rendered.googlebot.status_follow;
      result.rendered_googlebot_noarchive = rendered.googlebot.noarchive === true;
      result.rendered_googlebot_nosnippet = rendered.googlebot.nosnippet === true;
      result.rendered_googlebot_unavailable_after = rendered.googlebot.unavailable_after === true;
      result.rendered_googlebot_max_snippet = rendered.googlebot.max_snippet === true;
      result.rendered_googlebot_max_image_preview = rendered.googlebot.max_image_preview === true;
      result.rendered_googlebot_max_video_preview = rendered.googlebot.max_video_preview === true;
      result.rendered_googlebot_notranslate = rendered.googlebot.notranslate === true;
      result.rendered_googlebot_noimageindex = rendered.googlebot.noimageindex === true;
      result.rendered_googlebot_nocache = rendered.googlebot.nocache === true;

      result.rendered_googlebot_news_status_index = rendered.googlebot_news.status_index;
      result.rendered_googlebot_news_status_follow = rendered.googlebot_news.status_follow;
      result.rendered_googlebot_news_noarchive = rendered.googlebot_news.noarchive === true;
      result.rendered_googlebot_news_nosnippet = rendered.googlebot_news.nosnippet === true;
      result.rendered_googlebot_news_unavailable_after = rendered.googlebot_news.unavailable_after === true;
      result.rendered_googlebot_news_max_snippet = rendered.googlebot_news.max_snippet === true;
      result.rendered_googlebot_news_max_image_preview = rendered.googlebot_news.max_image_preview === true;
      result.rendered_googlebot_news_max_video_preview = rendered.googlebot_news.max_video_preview === true;
      result.rendered_googlebot_news_notranslate = rendered.googlebot_news.notranslate === true;
      result.rendered_googlebot_news_noimageindex = rendered.googlebot_news.noimageindex === true;
      result.rendered_googlebot_news_nocache = rendered.googlebot_news.nocache === true;

      // result.rendering_changed_robots_meta_tag = JSON.stringify(robots.raw) === JSON.stringify(robots.rendered);
    }
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

    result.has_rendered_canonical = false; // used in a NOT so must be set for a simple query to work
    if (canonicals.rendered && canonicals.rendered.html_link_canoncials) {
      result.has_rendered_canonical = canonicals.rendered.html_link_canoncials.length > 0;
    }

    result.has_raw_canonical = false; // used in a NOT so must be set for a simple query to work
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
  }

  var hreflangs = wpt_bodies.hreflangs;
  if (hreflangs) {

    if (hreflangs.raw && hreflangs.raw.values && hreflangs.rendered && hreflangs.rendered.values) {
      result.rendering_changed_hreflang = !compareStringArrays(hreflangs.raw.values, hreflangs.rendered.values);
    }

    if (hreflangs.rendered && hreflangs.rendered.values) {
      result.has_hreflang = hreflangs.rendered.values.length > 0;
    }

    if (hreflangs.http_header && hreflangs.http_header.values) {
      result.has_http_hreflang = hreflangs.http_header.values.length > 0;
    }

    result.has_rendered_hreflang = false; // used in a NOT so must be set for a simple query to work
    if (hreflangs.rendered && hreflangs.rendered.values) {
      result.has_rendered_hreflang = hreflangs.rendered.values.length > 0;
    }

    result.has_raw_hreflang = false; // used in a NOT so must be set for a simple query to work
    if (hreflangs.raw && hreflangs.raw.values) {
      result.has_raw_hreflang = hreflangs.raw.values.length > 0;
    }
  }

  var structured_data = wpt_bodies.structured_data;
  if (structured_data) {
    result.has_raw_jsonld_or_microdata = structured_data.raw && structured_data.raw.jsonld_and_microdata_types && structured_data.raw.jsonld_and_microdata_types.length > 0;
    result.has_rendered_jsonld_or_microdata = structured_data.rendered && structured_data.rendered.jsonld_and_microdata_types  && structured_data.rendered.jsonld_and_microdata_types.length > 0;

    if (structured_data.raw && structured_data.rendered) {
      result.rendering_changes_structured_data = JSON.stringify(structured_data.raw) !== JSON.stringify(structured_data.rendered);
    }
  }
} catch (e) {}
return result;
'''
;

select
    client,
    count(0) as total,

    # meta title inclusion
    as_percent(countif(wpt_bodies_info.n_titles > 0), count(0)) as pct_has_title_tag,

    # meta description inclusion
    as_percent(
        countif(wpt_bodies_info.n_meta_descriptions > 0), count(0)
    ) as pct_has_meta_description,

    # H1 inclusion
    as_percent(countif(wpt_bodies_info.n_h1 > 0), count(0)) as pct_has_h1,

    # H2 inclusion
    as_percent(countif(wpt_bodies_info.n_h2 > 0), count(0)) as pct_has_h2,

    # H3 inclusion
    as_percent(countif(wpt_bodies_info.n_h3 > 0), count(0)) as pct_has_h3,

    # H4 inclusion
    as_percent(countif(wpt_bodies_info.n_h4 > 0), count(0)) as pct_has_h4,

    # Non-empty H1 inclusion
    as_percent(
        countif(wpt_bodies_info.n_non_empty_h1 > 0), count(0)
    ) as pct_has_non_empty_h1,

    # Non-empty H2 inclusion
    as_percent(
        countif(wpt_bodies_info.n_non_empty_h2 > 0), count(0)
    ) as pct_has_non_empty_h2,

    # Non-empty H3 inclusion
    as_percent(
        countif(wpt_bodies_info.n_non_empty_h3 > 0), count(0)
    ) as pct_has_non_empty_h3,

    # Non-empty H4 inclusion
    as_percent(
        countif(wpt_bodies_info.n_non_empty_h4 > 0), count(0)
    ) as pct_has_non_empty_h4,

    # Same title and H1
    as_percent(
        countif(wpt_bodies_info.has_same_h1_title), count(0)
    ) as pct_has_same_h1_title,

    # Meta Robots inclusion
    as_percent(
        countif(wpt_bodies_info.robots_has_robots_meta_tag), count(0)
    ) as pct_has_meta_robots,

    # HTTP Header Robots inclusion
    as_percent(
        countif(wpt_bodies_info.robots_has_x_robots_tag), count(0)
    ) as pct_has_x_robots_tag,

    # Meta Robots and x-robots inclusion
    as_percent(
        countif(
            wpt_bodies_info.robots_has_robots_meta_tag
            and wpt_bodies_info.robots_has_x_robots_tag
        ),
        count(0)
    ) as pct_has_meta_robots_and_x_robots_tag,

    # Rendering changed Robots
    as_percent(
        countif(wpt_bodies_info.rendering_changed_robots_meta_tag), count(0)
    ) as pct_rendering_changed_robots_meta_tag,

    # Pages with canonical
    as_percent(countif(wpt_bodies_info.has_canonicals), count(0)) as pct_has_canonical,

    # Pages with self-canonical
    as_percent(
        countif(wpt_bodies_info.has_self_canonical), count(0)
    ) as pct_has_self_canonical,

    # Pages canonicalized
    as_percent(
        countif(wpt_bodies_info.is_canonicalized), count(0)
    ) as pct_is_canonicalized,

    # Pages with canonical in HTTP header
    as_percent(
        countif(wpt_bodies_info.has_http_canonical), count(0)
    ) as pct_http_canonical,

    # Pages with canonical in raw html
    as_percent(
        countif(wpt_bodies_info.has_raw_canonical), count(0)
    ) as pct_has_raw_canonical,

    # Pages with canonical in rendered html
    as_percent(
        countif(wpt_bodies_info.has_rendered_canonical), count(0)
    ) as pct_has_rendered_canonical,

    # Pages with canonical in rendered but not raw html
    as_percent(
        countif(
            wpt_bodies_info.has_rendered_canonical
            and not wpt_bodies_info.has_raw_canonical
        ),
        count(0)
    ) as pct_has_rendered_but_not_raw_canonical,

    # Pages with canonical mismatch
    as_percent(
        countif(wpt_bodies_info.has_canonical_mismatch), count(0)
    ) as pct_has_canonical_mismatch,

    # Pages with canonical conflict between raw and rendered
    as_percent(
        countif(wpt_bodies_info.rendering_changed_canonical), count(0)
    ) as pct_has_conflict_rendering_changed_canonical,

    # Pages with canonical conflict between raw and http header
    as_percent(
        countif(wpt_bodies_info.http_header_changed_canonical), count(0)
    ) as pct_has_conflict_http_header_changed_canonical,

    # Pages with canonical conflict between raw and http header
    as_percent(
        countif(
            wpt_bodies_info.http_header_changed_canonical
            or wpt_bodies_info.rendering_changed_canonical
        ),
        count(0)
    ) as pct_has_conflict_http_header_or_rendering_changed_canonical,

    # Pages with hreflang conflict between raw and rendered
    as_percent(
        countif(wpt_bodies_info.rendering_changed_hreflang), count(0)
    ) as pct_has_conflict_raw_rendered_hreflang,

    # Pages with hreflang
    as_percent(countif(wpt_bodies_info.has_hreflang), count(0)) as pct_has_hreflang,

    # Pages with http hreflang
    as_percent(
        countif(wpt_bodies_info.has_http_hreflang), count(0)
    ) as pct_has_http_hreflang,

    # Pages with rendered hreflang
    as_percent(
        countif(wpt_bodies_info.has_rendered_hreflang), count(0)
    ) as pct_has_rendered_hreflang,

    # Pages with raw hreflang
    as_percent(
        countif(wpt_bodies_info.has_raw_hreflang), count(0)
    ) as pct_has_raw_hreflang,

    # Pages with hreflang in rendered but not raw html
    as_percent(
        countif(
            wpt_bodies_info.has_rendered_hreflang
            and not wpt_bodies_info.has_raw_hreflang
        ),
        count(0)
    ) as pct_has_rendered_but_not_raw_hreflang,

    # Pages with raw jsonld or microdata
    as_percent(
        countif(wpt_bodies_info.has_raw_jsonld_or_microdata), count(0)
    ) as pct_has_raw_jsonld_or_microdata,

    # Pages with rendered jsonld or microdata
    as_percent(
        countif(wpt_bodies_info.has_rendered_jsonld_or_microdata), count(0)
    ) as pct_has_rendered_jsonld_or_microdata,

    # Pages with only rendered jsonld or microdata
    as_percent(
        countif(
            wpt_bodies_info.has_rendered_jsonld_or_microdata
            and not wpt_bodies_info.has_raw_jsonld_or_microdata
        ),
        count(0)
    ) as pct_has_only_rendered_jsonld_or_microdata,

    # Pages where rendering changed jsonld or microdata
    as_percent(
        countif(wpt_bodies_info.rendering_changes_structured_data), count(0)
    ) as pct_rendering_changes_structured_data,

    # http or https
    as_percent(countif(protocol = 'https'), count(0)) as pct_https,

    # meta robots
    as_percent(
        countif(wpt_bodies_info.rendered_otherbot_status_index), count(0)
    ) as pct_rendered_otherbot_status_index,
    as_percent(
        countif(wpt_bodies_info.rendered_otherbot_status_follow), count(0)
    ) as pct_rendered_otherbot_status_follow,
    as_percent(
        countif(wpt_bodies_info.rendered_otherbot_noarchive), count(0)
    ) as pct_rendered_otherbot_noarchive,
    as_percent(
        countif(wpt_bodies_info.rendered_otherbot_nosnippet), count(0)
    ) as pct_rendered_otherbot_nosnippet,
    as_percent(
        countif(wpt_bodies_info.rendered_otherbot_unavailable_after), count(0)
    ) as pct_rendered_otherbot_unavailable_after,
    as_percent(
        countif(wpt_bodies_info.rendered_otherbot_max_snippet), count(0)
    ) as pct_rendered_otherbot_max_snippet,
    as_percent(
        countif(wpt_bodies_info.rendered_otherbot_max_image_preview), count(0)
    ) as pct_rendered_otherbot_max_image_preview,
    as_percent(
        countif(wpt_bodies_info.rendered_otherbot_max_video_preview), count(0)
    ) as pct_rendered_otherbot_max_video_preview,
    as_percent(
        countif(wpt_bodies_info.rendered_otherbot_notranslate), count(0)
    ) as pct_rendered_otherbot_notranslate,
    as_percent(
        countif(wpt_bodies_info.rendered_otherbot_noimageindex), count(0)
    ) as pct_rendered_otherbot_noimageindex,
    as_percent(
        countif(wpt_bodies_info.rendered_otherbot_nocache), count(0)
    ) as pct_rendered_otherbot_nocache,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_status_index), count(0)
    ) as pct_rendered_googlebot_status_index,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_status_follow), count(0)
    ) as pct_rendered_googlebot_status_follow,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_noarchive), count(0)
    ) as pct_rendered_googlebot_noarchive,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_nosnippet), count(0)
    ) as pct_rendered_googlebot_nosnippet,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_unavailable_after), count(0)
    ) as pct_rendered_googlebot_unavailable_after,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_max_snippet), count(0)
    ) as pct_rendered_googlebot_max_snippet,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_max_image_preview), count(0)
    ) as pct_rendered_googlebot_max_image_preview,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_max_video_preview), count(0)
    ) as pct_rendered_googlebot_max_video_preview,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_notranslate), count(0)
    ) as pct_rendered_googlebot_notranslate,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_noimageindex), count(0)
    ) as pct_rendered_googlebot_noimageindex,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_nocache), count(0)
    ) as pct_rendered_googlebot_nocache,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_news_status_index), count(0)
    ) as pct_rendered_googlebot_news_status_index,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_news_status_follow), count(0)
    ) as pct_rendered_googlebot_news_status_follow,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_news_noarchive), count(0)
    ) as pct_rendered_googlebot_news_noarchive,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_news_nosnippet), count(0)
    ) as pct_rendered_googlebot_news_nosnippet,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_news_unavailable_after), count(0)
    ) as pct_rendered_googlebot_news_unavailable_after,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_news_max_snippet), count(0)
    ) as pct_rendered_googlebot_news_max_snippet,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_news_max_image_preview), count(0)
    ) as pct_rendered_googlebot_news_max_image_preview,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_news_max_video_preview), count(0)
    ) as pct_rendered_googlebot_news_max_video_preview,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_news_notranslate), count(0)
    ) as pct_rendered_googlebot_news_notranslate,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_news_noimageindex), count(0)
    ) as pct_rendered_googlebot_news_noimageindex,
    as_percent(
        countif(wpt_bodies_info.rendered_googlebot_news_nocache), count(0)
    ) as pct_rendered_googlebot_news_nocache

from
    (
        select
            _table_suffix as client,
            split(url, ':')[offset(0)] as protocol,
            get_wpt_bodies_info(
                json_extract_scalar(payload, '$._wpt_bodies')
            ) as wpt_bodies_info
        from `httparchive.pages.2020_08_01_*`
    )
group by client
