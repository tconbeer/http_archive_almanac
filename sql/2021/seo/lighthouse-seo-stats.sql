# standardSQL
# Lighthouse SEO stats
# live run is about $9
create temporary function iscrawlabledetails(report string)
returns struct < disallow bool,
noindex bool,
both bool,
neither bool > deterministic
language js
as '''
var result = {disallow: false, noindex: false};
try {
    var $ = JSON.parse(report);
    var items = $.audits['is-crawlable'].details.items;
    result.noindex = items.filter(item => item.source.type ==='node').length > 0;
    result.disallow = items.filter(item => item.source.type ==='source-location').length > 0;
} catch (e) {
}
return result;
'''
;

select
    count(0) as total,

    countif(is_canonical) as is_canonical,
    safe_divide(countif(is_canonical), count(0)) as pct_is_canonical,

    countif(has_title) as has_title,
    safe_divide(countif(has_title), count(0)) as pct_has_title,

    countif(has_meta_description) as has_meta_description,
    safe_divide(countif(has_meta_description), count(0)) as pct_has_meta_description,

    countif(has_title and has_meta_description) as has_title_and_meta_description,
    safe_divide(
        countif(has_title and has_meta_description), count(0)
    ) as pct_has_title_and_meta_description,

    countif(img_alt_on_all) as img_alt_on_all,
    safe_divide(countif(img_alt_on_all), count(0)) as pct_img_alt_on_all,

    countif(link_text_descriptive) as link_text_descriptive,
    safe_divide(countif(link_text_descriptive), count(0)) as pct_link_text_descriptive,

    countif(legible_font_size) as legible_font_size,
    safe_divide(countif(legible_font_size), count(0)) as pct_legible_font_size,

    countif(heading_order_valid) as heading_order_valid,
    safe_divide(countif(heading_order_valid), count(0)) as pct_heading_order_valid,

    countif(robots_txt_valid) as robots_txt_valid,
    safe_divide(countif(robots_txt_valid), count(0)) as pct_robots_txt_valid,

    countif(is_crawlable) as is_crawlable,
    safe_divide(countif(is_crawlable), count(0)) as pct_is_crawlable,

    countif(is_crawlable_details.noindex) as noindex,
    safe_divide(countif(is_crawlable_details.noindex), count(0)) as pct_noindex,

    countif(is_crawlable_details.disallow) as disallow,
    safe_divide(countif(is_crawlable_details.disallow), count(0)) as pct_disallow,

    countif(
        is_crawlable_details.disallow and is_crawlable_details.noindex
    ) as disallow_noindex,
    safe_divide(
        countif(is_crawlable_details.disallow and is_crawlable_details.noindex),
        count(0)
    ) as pct_disallow_noindex,

    countif(
        not (is_crawlable_details.disallow) and not (is_crawlable_details.noindex)
    ) as allow_index,
    safe_divide(
        countif(
            not (is_crawlable_details.disallow) and not (is_crawlable_details.noindex)
        ),
        count(0)
    ) as pct_allow_index,

    countif(
        is_crawlable_details.disallow and not (is_crawlable_details.noindex)
    ) as disallow_index,
    safe_divide(
        countif(is_crawlable_details.disallow and not (is_crawlable_details.noindex)),
        count(0)
    ) as pct_disallow_index,

    countif(
        not (is_crawlable_details.disallow) and is_crawlable_details.noindex
    ) as allow_noindex,
    safe_divide(
        countif(not (is_crawlable_details.disallow) and is_crawlable_details.noindex),
        count(0)
    ) as pct_allow_noindex
from
    (
        select
            json_extract_scalar(report, '$.audits.is-crawlable.score')
            = '1' as is_crawlable,
            json_extract_scalar(report, '$.audits.canonical.score')
            = '1' as is_canonical,
            json_extract_scalar(report, '$.audits.document-title.score')
            = '1' as has_title,
            json_extract_scalar(report, '$.audits.meta-description.score')
            = '1' as has_meta_description,
            json_extract_scalar(report, '$.audits.image-alt.score')
            = '1' as img_alt_on_all,
            json_extract_scalar(report, '$.audits.robots-txt.score')
            = '1' as robots_txt_valid,
            json_extract_scalar(report, '$.audits.link-text.score')
            = '1' as link_text_descriptive,
            json_extract_scalar(report, '$.audits.font-size.score')
            = '1' as legible_font_size,
            json_extract_scalar(report, '$.audits.heading-order.score')
            = '1' as heading_order_valid,
            iscrawlabledetails(report) as is_crawlable_details
        from `httparchive.lighthouse.2021_07_01_*`
    )
