# standardSQL
# Whether making a If-Modified-Since request returns a 304 if the content have not
# changed (as seen from Last-Modified)
select
    client,
    count(0) as total_requests,
    countif(status = 304) as total_304,
    countif(
        not uses_etag and uses_last_modified and uses_if_modified and no_change
    ) as total_expected_304,
    countif(
        not uses_etag
        and uses_last_modified
        and uses_if_modified
        and no_change
        and status = 304
    ) as total_actual_304,
    countif(status = 304) / count(0) as pct_304,
    countif(not uses_etag and uses_last_modified and uses_if_modified and no_change)
    / countif(status = 304) as pct_expected_304,
    countif(
        not uses_etag
        and uses_last_modified
        and uses_if_modified
        and no_change
        and status = 304
    ) / countif(not uses_etag and uses_last_modified and uses_if_modified and no_change
    ) as pct_actual_304
from
    (
        select
            _table_suffix as client,
            status,
            trim(resp_last_modified) = trim(req_if_modified_since) as no_change,
            trim(resp_last_modified) != '' as uses_last_modified,
            trim(req_if_modified_since) != '' as uses_if_modified,
            trim(resp_etag) != '' as uses_etag
        from `httparchive.summary_requests.2021_07_01_*`
    )
group by client
order by client
