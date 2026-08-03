# standardSQL
# 09_32b: % of pages using alt tags
create temporary function hasimages(payload string)
returns boolean
language js
as '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count);
  return (elements.img || 0) > 0;
} catch (e) {
  return false;
}
'''
;

select
    client,
    count(0) as total_sites,
    countif(has_images) as total_with_images,
    countif(has_images and has_alt_tags) as total_with_an_alt_tag,

    round(countif(has_images) * 100 / count(0), 2) as perc_with_images,
    round(
        countif(has_images and has_alt_tags) * 100 / countif(has_images), 2
    ) as perc_with_an_alt_tag
from
    (
        select _table_suffix as client, url as page, hasimages(payload) as has_images
        from `httparchive.pages.2019_07_01_*`
    )
join
    (
        select client, page, regexp_contains(body, r'(?i)alt=[\'"]?') as has_alt_tags
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    ) using (client, page)
group by client
