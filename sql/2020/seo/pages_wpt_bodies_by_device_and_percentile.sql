# standardSQL
# percientile data from wpt_bodies per device
# returns all the data we need from _wpt_bodies
create temporary function get_wpt_bodies_info(wpt_bodies_string string)
returns struct < title_words int64,
title_characters int64,
links_other_property int64,
links_same_site int64,
links_same_property int64,
visible_words_rendered_count int64,
visible_words_raw_count int64,
meta_description_words int64,
meta_description_characters int64,
image_links int64,
text_links int64,
hash_link int64,
hash_only_link int64,
javascript_void_links int64,
same_page_jumpto_total int64,
same_page_dynamic_total int64,
same_page_other_total int64
> language js
as '''
var result = {};
try {
    var wpt_bodies = JSON.parse(wpt_bodies_string);

    if (Array.isArray(wpt_bodies) || typeof wpt_bodies != 'object') return result;

    if (wpt_bodies.title) {
      if (wpt_bodies.title.rendered) {
        result.title_words = wpt_bodies.title.rendered.primary.words;
        result.title_characters = wpt_bodies.title.rendered.primary.characters;
      }
    }
    if (wpt_bodies.visible_words) {
      result.visible_words_rendered_count = wpt_bodies.visible_words.rendered;
      result.visible_words_raw_count = wpt_bodies.visible_words.raw;
    }

    if (wpt_bodies.anchors && wpt_bodies.anchors.rendered) {
      var anchors_rendered = wpt_bodies.anchors.rendered;

      result.links_other_property = anchors_rendered.other_property;
      result.links_same_site = anchors_rendered.same_site;
      result.links_same_property = anchors_rendered.same_property;

      result.image_links = anchors_rendered.image_links;
      result.text_links = anchors_rendered.text_links;

      result.hash_link = anchors_rendered.hash_link;
      result.hash_only_link = anchors_rendered.hash_only_link;
      result.javascript_void_links = anchors_rendered.javascript_void_links;
      result.same_page_jumpto_total = anchors_rendered.same_page.jumpto.total;
      result.same_page_dynamic_total = anchors_rendered.same_page.dynamic.total;
      result.same_page_other_total = anchors_rendered.same_page.other.total;

    }

    if (wpt_bodies.meta_description && wpt_bodies.meta_description.rendered && wpt_bodies.meta_description.rendered.primary) {

      result.meta_description_characters = wpt_bodies.meta_description.rendered.primary.characters;
      result.meta_description_words = wpt_bodies.meta_description.rendered.primary.words;

    }

} catch (e) {}
return result;
'''
;

select
    percentile,
    client,
    count(distinct url) as total,

    # title
    approx_quantiles(
        wpt_bodies_info.title_words, 1000) [offset (percentile * 10)
    ] as title_words,
    approx_quantiles(
        wpt_bodies_info.title_characters, 1000) [offset (percentile * 10)
    ] as title_characters,

    # meta description
    approx_quantiles(
        wpt_bodies_info.meta_description_words, 1000) [offset (percentile * 10)
    ] as meta_description_words,
    approx_quantiles(
        wpt_bodies_info.meta_description_characters, 1000) [offset (percentile * 10)
    ] as meta_description_characters,

    # links
    approx_quantiles(
        wpt_bodies_info.links_other_property, 1000) [offset (percentile * 10)
    ] as outgoing_links_external,
    approx_quantiles(
        wpt_bodies_info.links_same_property
        + wpt_bodies_info.links_same_site
        + wpt_bodies_info.links_other_property,
        1000
    ) [offset (percentile * 10)
    ] as outgoing_links,
    approx_quantiles(
        wpt_bodies_info.links_same_property + wpt_bodies_info.links_same_site,
        1000
    ) [offset (percentile * 10)
    ] as outgoing_links_internal,

    approx_quantiles(
        wpt_bodies_info.image_links, 1000) [offset (percentile * 10)
    ] as image_links,
    approx_quantiles(
        wpt_bodies_info.text_links, 1000) [offset (percentile * 10)
    ] as text_links,

    approx_quantiles(
        wpt_bodies_info.hash_link, 1000) [offset (percentile * 10)
    ] as hash_links,
    approx_quantiles(
        wpt_bodies_info.hash_only_link, 1000) [offset (percentile * 10)
    ] as hash_only_links,
    approx_quantiles(
        wpt_bodies_info.javascript_void_links, 1000) [offset (percentile * 10)
    ] as javascript_void_links,
    approx_quantiles(
        wpt_bodies_info.same_page_jumpto_total, 1000) [offset (percentile * 10)
    ] as same_page_jumpto_links,
    approx_quantiles(
        wpt_bodies_info.same_page_dynamic_total, 1000) [offset (percentile * 10)
    ] as same_page_dynamic_links,
    approx_quantiles(
        wpt_bodies_info.same_page_other_total, 1000) [offset (percentile * 10)
    ] as same_page_other_links,

    # percent of links are image links
    round(
        approx_quantiles(
            safe_divide(
                wpt_bodies_info.image_links,
                wpt_bodies_info.image_links + wpt_bodies_info.text_links
            ),
            1000
        ) [offset (percentile * 10)
        ],
        4
    ) as image_links_percent,

    # words
    approx_quantiles(
        wpt_bodies_info.visible_words_rendered_count, 1000) [offset (percentile * 10)
    ] as visible_words_rendered,
    approx_quantiles(
        wpt_bodies_info.visible_words_raw_count, 1000) [offset (percentile * 10)
    ] as visible_words_raw

from
    (
        select
            _table_suffix as client,
            percentile,
            url,
            get_wpt_bodies_info(
                json_extract_scalar(payload, '$._wpt_bodies')
            ) as wpt_bodies_info
        from
            `httparchive.pages.2020_08_01_*`,
            unnest( [10, 25, 50, 75, 90]) as percentile
    )
group by percentile, client
order by percentile, client
