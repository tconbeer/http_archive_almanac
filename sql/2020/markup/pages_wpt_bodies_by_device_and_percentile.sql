# standardSQL
# percientile data from wpt_bodies per device
# returns all the data we need from _wpt_bodies
create temporary function get_wpt_bodies_info(wpt_bodies_string string)
returns
    struct<
        comment_count int64,
        conditional_comment_count int64,
        head_size int64,
        no_h1 bool,
        target_blank_total int64,
        target_blank_noopener_noreferrer_total int64
    >
language js
as
    '''
var result = {};
try {
    var wpt_bodies = JSON.parse(wpt_bodies_string);

    if (Array.isArray(wpt_bodies) || typeof wpt_bodies != 'object') return result;

    if (wpt_bodies.raw_html) {
      result.comment_count = wpt_bodies.raw_html.comment_count; // M103
      result.conditional_comment_count = wpt_bodies.raw_html.conditional_comment_count; // M104
      result.head_size = wpt_bodies.raw_html.head_size; // M234
    }

    result.no_h1 = !wpt_bodies.headings || !wpt_bodies.headings.rendered || !wpt_bodies.headings.rendered.h1 || !wpt_bodies.headings.rendered.h1.total || wpt_bodies.headings.rendered.h1.total === 0;

    if (wpt_bodies.anchors && wpt_bodies.anchors.rendered && wpt_bodies.anchors.rendered.target_blank) {
      result.target_blank_total = wpt_bodies.anchors.rendered.target_blank.total;
      result.target_blank_noopener_noreferrer_total = wpt_bodies.anchors.rendered.target_blank.noopener_noreferrer;
    }

} catch (e) {}
return result;
'''
;

select
    percentile,
    client,
    count(distinct url) as total,

    # Comments per page
    approx_quantiles(wpt_bodies_info.comment_count, 1000)[
        offset(percentile * 10)
    ] as comment_count_m103,
    approx_quantiles(wpt_bodies_info.conditional_comment_count, 1000)[
        offset(percentile * 10)
    ] as conditional_comment_count_m105,

    # size of the head section in characters
    approx_quantiles(wpt_bodies_info.head_size, 1000)[
        offset(percentile * 10)
    ] as head_size_m234
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
            `httparchive.pages.2020_08_01_*`, unnest([10, 25, 50, 75, 90]) as percentile
    )
group by percentile, client
order by percentile, client
