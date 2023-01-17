# standardSQL
# 04_21: % of pages having a hero image
select
    client,
    countif(has_hero_image) as hero_image,
    countif(has_hero_bgimage) as hero_bg_image,
    count(0) as total,
    round(countif(has_hero_image) * 100 / count(0), 2) as pct_hero_img,
    round(countif(has_hero_bgimage) * 100 / count(0), 2) as pct_hero_bgimg
from
    (
        select
            _table_suffix as client,
            json_extract_scalar(payload, "$['_heroElementTimes.Image']")
            is not null as has_hero_image,
            json_extract_scalar(payload, "$['_heroElementTimes.BackgroundImage']")
            is not null as has_hero_bgimage
        from `httparchive.pages.2019_07_01_*`
    )
group by client
