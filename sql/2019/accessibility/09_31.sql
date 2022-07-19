# standardSQL
# 09_31: Sites containing links and buttons with accessible text
select
    count(0) as total_sites,
    countif(uses_buttons) as total_using_buttons,
    countif(uses_links) as total_using_links,
    countif(uses_either) as total_using_either,

    round(
        countif(uses_buttons and good_or_na_buttons) * 100 / countif(uses_buttons), 2
    ) as perc_good_buttons,
    round(
        countif(uses_links and good_or_na_links) * 100 / countif(uses_links), 2
    ) as perc_good_links,
    round(
        countif(uses_either and good_or_na_buttons and good_or_na_links)
        * 100
        / countif(uses_either),
        2
    ) as perc_both_good
from
    (
        select
            button_name_score is not null as uses_buttons,
            link_name_score is not null as uses_links,
            button_name_score is not null or link_name_score is not null as uses_either,

            ifnull(cast(button_name_score as numeric), 1) = 1 as good_or_na_buttons,
            ifnull(cast(link_name_score as numeric), 1) = 1 as good_or_na_links
        from
            (
                select
                    json_extract_scalar(
                        report, '$.audits.button-name.score'
                    ) as button_name_score,
                    json_extract_scalar(
                        report, '$.audits.link-name.score'
                    ) as link_name_score
                from `httparchive.lighthouse.2019_07_01_mobile`
            )
    )
