# standardSQL
# Use of Cache-Control, max-age in Cache-Control, and Expires
select
    client,
    count(0) as total_requests,
    countif(uses_cache_control) as total_using_cache_control,
    countif(uses_max_age) as total_using_max_age,
    countif(uses_expires) as total_using_expires,
    countif(uses_max_age and uses_expires) as total_using_max_age_and_expires,
    countif(uses_cache_control and uses_expires) as total_using_both,
    countif(not uses_cache_control and not uses_expires) as total_using_neither,
    countif(uses_cache_control and not uses_expires) as total_using_only_cache_control,
    countif(not uses_cache_control and uses_expires) as total_using_only_expires,
    countif(uses_cache_control) / count(0) as pct_cache_control,
    countif(uses_max_age) / count(0) as pct_using_max_age,
    countif(uses_expires) / count(0) as pct_using_expires,
    countif(uses_max_age and uses_expires) / count(0) as pct_using_max_age_and_expires,
    countif(uses_cache_control and uses_expires) / count(0) as pct_using_both,
    countif(not uses_cache_control and not uses_expires) / count(
        0
    ) as pct_using_neither,
    countif(uses_cache_control and not uses_expires) / count(
        0
    ) as pct_using_only_cache_control,
    countif(not uses_cache_control and uses_expires) / count(
        0
    ) as pct_using_only_expires
from
    (
        select
            _table_suffix as client,
            trim(resp_expires) != '' as uses_expires,
            trim(resp_cache_control) != '' as uses_cache_control,
            regexp_contains(
                resp_cache_control, r'(?i)max-age\s*=\s*[0-9]+'
            ) as uses_max_age
        from `httparchive.summary_requests.2020_08_01_*`
    )
group by client
