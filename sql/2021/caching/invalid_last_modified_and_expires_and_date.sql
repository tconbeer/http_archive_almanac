# standardSQL
# Valid date in Last-Modified, Expires, and Date headers
select
    client,
    count(0) as total_requests,
    countif(uses_date) as total_using_date,
    countif(uses_last_modified) as total_using_last_modified,
    countif(uses_expires) as total_using_expires,
    countif(uses_date and not has_valid_date) as total_using_invalid_date,
    countif(
        uses_last_modified and not has_valid_last_modified
    ) as total_using_invalid_last_modified,
    countif(uses_expires and not has_valid_expires) as total_using_invalid_expires,
    countif(uses_date) / count(0) as pct_using_date,
    countif(uses_last_modified) / count(0) as pct_using_last_modified,
    countif(uses_expires) / count(0) as pct_using_expires,
    countif(uses_date and not has_valid_date) / count(
        uses_date
    ) as pct_using_invalid_date,
    countif(uses_last_modified and not has_valid_last_modified) / count(
        uses_last_modified
    ) as pct_using_invalid_last_modified,
    countif(uses_expires and not has_valid_expires) / count(
        uses_expires
    ) as pct_using_invalid_expires
from
    (
        select
            _table_suffix as client,
            trim(resp_date) != '' as uses_date,
            trim(resp_last_modified) != '' as uses_last_modified,
            trim(resp_expires) != '' as uses_expires,
            regexp_contains(
                trim(resp_date),
                r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), \d{1,2} (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d{4} \d{2}:\d{2}:\d{2} GMT$'
            ) as has_valid_date,
            regexp_contains(
                trim(resp_last_modified),
                r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), \d{1,2} (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d{4} \d{2}:\d{2}:\d{2} GMT$'
            ) as has_valid_last_modified,
            regexp_contains(
                trim(resp_expires),
                r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), \d{1,2} (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d{4} \d{2}:\d{2}:\d{2} GMT$'
            ) as has_valid_expires
        from `httparchive.summary_requests.2021_07_01_*`
    )
group by client
