# standardSQL
# Use of Cache-Control, max-age in Cache-Control, and Expires
with
    summary_requests as (
        select '2019' as year, _table_suffix as client, *
        from `httparchive.summary_requests.2019_07_01_*`
        union all
        select '2020' as year, _table_suffix as client, *
        from `httparchive.summary_requests.2020_08_01_*`
        union all
        select '2021' as year, _table_suffix as client, *
        from `httparchive.summary_requests.2021_07_01_*`
    )

select
    year,
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

    countif(uses_no_etag) as total_using_no_etag,
    countif(uses_etag) as total_using_etag,
    countif(uses_weak_etag) as total_using_weak_etag,
    countif(uses_strong_etag) as total_using_strong_etag,
    countif(
        not uses_weak_etag and not uses_strong_etag and uses_etag
    ) as total_using_invalid_etag,
    countif(uses_last_modified) as total_using_last_modified,
    countif(uses_etag and uses_last_modified) as total_using_both,
    countif(not uses_etag and not uses_last_modified) as total_using_neither,

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
    ) as pct_using_only_expires,

    countif(uses_no_etag) / count(0) as pct_using_no_etag,
    countif(uses_etag) / count(0) as pct_using_etag,
    countif(uses_weak_etag) / count(0) as pct_using_weak_etag,
    countif(uses_strong_etag) / count(0) as pct_using_strong_etag,
    countif(not uses_weak_etag and not uses_strong_etag and uses_etag) / count(
        0
    ) as pct_using_invalid_etag,
    countif(uses_last_modified) / count(0) as pct_using_last_modified,
    countif(uses_etag and uses_last_modified) / count(0) as pct_using_both,
    countif(not uses_etag and not uses_last_modified) / count(0) as pct_using_neither
from
    (
        select
            year,
            client,
            trim(resp_expires) != '' as uses_expires,
            trim(resp_cache_control) != '' as uses_cache_control,
            regexp_contains(
                resp_cache_control, r'(?i)max-age\s*=\s*[0-9]+'
            ) as uses_max_age,
            trim(resp_etag) = '' as uses_no_etag,
            trim(resp_etag) != '' as uses_etag,
            trim(resp_last_modified) != '' as uses_last_modified,
            regexp_contains(trim(resp_etag), '^W/".*"') as uses_weak_etag,
            regexp_contains(trim(resp_etag), '^".*"') as uses_strong_etag
        from summary_requests
    )
group by year, client
order by year, client
