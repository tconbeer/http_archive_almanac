# standardSQL
# Presence of Last-Modified and ETag header, statistics on weak, strong, and invalid
# ETag.
select
    client,
    count(0) as total_requests,
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
    countif(uses_no_etag) / count(0) as pct_using_no_etag,
    countif(uses_etag) / count(0) as pct_using_etag,
    countif(uses_weak_etag) / count(0) as pct_using_weak_etag,
    countif(uses_strong_etag) / count(0) as pct_using_strong_etag,
    countif(not uses_weak_etag and not uses_strong_etag and uses_etag)
    / count(0) as pct_using_invalid_etag,
    countif(uses_last_modified) / count(0) as pct_using_last_modified,
    countif(uses_etag and uses_last_modified) / count(0) as pct_using_both,
    countif(not uses_etag and not uses_last_modified) / count(0) as pct_using_neither
from
    (
        select
            _table_suffix as client,
            trim(resp_etag) = '' as uses_no_etag,
            trim(resp_etag) != '' as uses_etag,
            trim(resp_last_modified) != '' as uses_last_modified,
            regexp_contains(trim(resp_etag), '^W/".*"') as uses_weak_etag,
            regexp_contains(trim(resp_etag), '^".*"') as uses_strong_etag
        from `httparchive.summary_requests.2019_07_01_*`
    )
group by client
