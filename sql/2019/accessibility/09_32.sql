# standardSQL
# 09_32: Sites properly using alt tags (or role=none and role=presentation) on image
# and button image elements
select
    count(0) as total_sites,
    countif(uses_any_images) as total_using_any_images,
    countif(uses_img_elements) as total_using_img_elements,
    countif(uses_input_img_elements) as total_using_input_img_elements,

    round(
        countif(uses_img_elements and good_or_na_image_alts)
        * 100
        / countif(uses_img_elements),
        2
    ) as perc_good_img_element_alts,
    round(
        countif(uses_input_img_elements and good_or_na_input_img_alts)
        * 100
        / countif(uses_input_img_elements),
        2
    ) as perc_good_input_img_alts,
    round(
        countif(uses_any_images and good_or_na_image_alts and good_or_na_input_img_alts)
        * 100
        / countif(uses_any_images),
        2
    ) as perc_good_img_alts
from
    (
        select
            image_alt_score is not null as uses_img_elements,
            input_image_alt_score is not null as uses_input_img_elements,
            image_alt_score is not null
            or input_image_alt_score is not null as uses_any_images,

            ifnull(cast(image_alt_score as numeric), 1) = 1 as good_or_na_image_alts,
            ifnull(cast(input_image_alt_score as numeric), 1)
            = 1 as good_or_na_input_img_alts
        from
            (
                select
                    json_extract_scalar(
                        report, '$.audits.image-alt.score'
                    ) as image_alt_score,
                    json_extract_scalar(
                        report, '$.audits.input-image-alt.score'
                    ) as input_image_alt_score
                from `httparchive.lighthouse.2019_07_01_mobile`
            )
    )
