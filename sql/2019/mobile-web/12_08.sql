# standardSQL
# password-inputs-can-be-pasted-into
select
    count(0) as total_pages,
    countif(password_score is not null) as applicable_pages,

    countif(cast(password_score as numeric) = 1) as total_allowing,
    round(
        countif(cast(password_score as numeric) = 1)
        * 100 / countif(
            password_score is not null
        ),
        2
    ) as perc_allowing
from
    (
        select
            url,
            json_extract_scalar(
                report, '$.audits.password-inputs-can-be-pasted-into.score'
            ) as password_score
        from `httparchive.lighthouse.2019_07_01_mobile`
    )
