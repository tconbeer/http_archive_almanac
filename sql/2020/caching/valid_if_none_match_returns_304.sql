# Whether making a If-None-Match request returns a 304 if the content have not changed
# (as seen from ETag)
select
    client,
    count(0) as total_requests,
    countif(status = 304) as total_304,
    countif(uses_etag and uses_if_non_match and no_change) as total_expected_304,
    countif(
        uses_etag and uses_if_non_match and no_change and status = 304
    ) as total_actual_304,
    countif(status = 304) / count(0) as pct_304,
    countif(uses_etag and uses_if_non_match and no_change)
    / countif(status = 304) as pct_expected_304,
    countif(uses_etag and uses_if_non_match and no_change and status = 304)
    / countif(uses_etag and uses_if_non_match and no_change) as pct_actual_304
from
    (
        select
            _table_suffix as client,
            status,
            trim(resp_etag) = trim(req_if_none_match) as no_change,
            trim(resp_etag) != '' as uses_etag,
            trim(req_if_none_match) != '' as uses_if_non_match
        from `httparchive.summary_requests.2020_08_01_*`
    )
group by client
order by client
