# standardSQL
# Gather SEO data from lighthouse
# live run is about $9
# helper to create percent fields
create temp function as_percent(freq float64, total float64) returns float64 as (
    round(safe_divide(freq, total), 4)
)
;

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
    as_percent(countif(is_canonical), count(0)) as pct_is_canonical,

    countif(has_title) as has_title,
    as_percent(countif(has_title), count(0)) as pct_has_title,

    countif(has_meta_description) as has_meta_description,
    as_percent(countif(has_meta_description), count(0)) as pct_has_meta_description,

    countif(has_title and has_meta_description) as has_title_and_meta_description,
    as_percent(
        countif(has_title and has_meta_description), count(0)
    ) as pct_has_title_and_meta_description,

    countif(img_alt_on_all) as img_alt_on_all,
    as_percent(countif(img_alt_on_all), count(0)) as pct_img_alt_on_all,

    countif(link_text_descriptive) as link_text_descriptive,
    as_percent(countif(link_text_descriptive), count(0)) as pct_link_text_descriptive,

    countif(robots_txt_valid) as robots_txt_valid,
    as_percent(countif(robots_txt_valid), count(0)) as pct_robots_txt_valid,

    countif(is_crawlable) as is_crawlable,
    as_percent(countif(is_crawlable), count(0)) as pct_is_crawlable,

    countif(is_crawlable_details.noindex) as noindex,
    as_percent(countif(is_crawlable_details.noindex), count(0)) as pct_noindex,

    countif(is_crawlable_details.disallow) as disallow,
    as_percent(countif(is_crawlable_details.disallow), count(0)) as pct_disallow,

    countif(
        is_crawlable_details.disallow and is_crawlable_details.noindex
    ) as disallow_noindex,
    as_percent(
        countif(is_crawlable_details.disallow and is_crawlable_details.noindex),
        count(0)
    ) as pct_disallow_noindex,

    countif(
        not (is_crawlable_details.disallow) and not (is_crawlable_details.noindex)
    ) as allow_index,
    as_percent(
        countif(
            not (is_crawlable_details.disallow) and not (is_crawlable_details.noindex)
        ),
        count(0)
    ) as pct_allow_index,

    countif(
        is_crawlable_details.disallow and not (is_crawlable_details.noindex)
    ) as disallow_index,
    as_percent(
        countif(is_crawlable_details.disallow and not (is_crawlable_details.noindex)),
        count(0)
    ) as pct_disallow_index,

    countif(
        not (is_crawlable_details.disallow) and is_crawlable_details.noindex
    ) as allow_noindex,
    as_percent(
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
            iscrawlabledetails(report) as is_crawlable_details
        from `httparchive.lighthouse.2020_08_01_*`
    )
