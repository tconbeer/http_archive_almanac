# standardSQL
# 16_05: Availability of Last-Modified vs. ETag validators
select
    client,
    count(0) as total_requests,

    countif(uses_etag) as total_etag,
    countif(uses_last_modified) as total_last_modified,
    countif(uses_etag and uses_last_modified) as total_using_both,
    countif(not uses_etag and not uses_last_modified) as total_using_neither,

    round(countif(uses_etag) * 100 / count(0), 2) as pct_etag,
    round(countif(uses_last_modified) * 100 / count(0), 2) as pct_last_modified,
    round(
        countif(uses_etag and uses_last_modified) * 100 / count(0), 2
    ) as pct_uses_both,
    round(
        countif(not uses_etag and not uses_last_modified) * 100 / count(0), 2
    ) as pct_uses_neither
from
    (
        select
            client,
            trim(resp_etag) != '' as uses_etag,
            trim(resp_last_modified) != '' as uses_last_modified
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
    )
group by client
