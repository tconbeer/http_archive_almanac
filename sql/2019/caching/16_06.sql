# standardSQL
# 16_06: Validity of Dates in Last-Modified and Date headers
select
    client,
    count(0) as total_requests,

    countif(uses_date) as total_date,
    countif(uses_last_modified) as total_last_modified,
    countif(uses_date and uses_last_modified) as total_using_both,
    round(
        countif(uses_date and uses_last_modified) * 100 / count(0), 2
    ) as pct_req_using_both,

    countif(uses_date and not has_valid_date_header) as total_invalid_date_header,
    countif(
        uses_last_modified and not has_valid_last_modified
    ) as total_invalid_last_modified,
    countif(
        (uses_date and not has_valid_date_header) or (
            uses_last_modified and not has_valid_last_modified
        )
    ) as total_has_invalid_header,

    round(
        countif(uses_date and not has_valid_date_header) * 100 / countif(uses_date), 2
    ) as pct_invalid_date_header,
    round(
        countif(uses_last_modified and not has_valid_last_modified) * 100 / countif(
            uses_last_modified
        ),
        2
    ) as pct_invalid_last_modified,
    round(
        countif(
            (uses_date and not has_valid_date_header) or (
                uses_last_modified and not has_valid_last_modified
            )
        ) * 100 / count(0),
        2
    ) as pct_req_with_invalid_header
from
    (
        select
            client,
            trim(resp_date) != '' as uses_date,
            trim(resp_last_modified) != '' as uses_last_modified,

            regexp_contains(
                trim(resp_date),
                r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), \d{1,2} (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d{4} \d{2}:\d{2}:\d{2} GMT$'
            ) as has_valid_date_header,
            regexp_contains(
                trim(resp_last_modified),
                r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), \d{1,2} (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d{4} \d{2}:\d{2}:\d{2} GMT$'
            ) as has_valid_last_modified
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
    )
group by client
