# standardSQL
# Responses with Set-cookie header, absence of no-store means cacheable (max-age,
# Expires, or heuristic)
select
    client,
    count(0) as total_requests,
    countif(not uses_no_store) as total_cacheable,
    countif(not uses_no_store and uses_cookies) as total_cacheable_set_cookie,
    countif(
        not uses_no_store and not uses_cookies
    ) as total_cacheable_without_set_cookie,
    countif(
        not uses_no_store and uses_cookies and uses_private
    ) as total_pvt_cacheable_set_cookie,
    countif(
        not uses_no_store and uses_cookies and not uses_private
    ) as total_pvt_public_cacheable_set_cookie,
    countif(not uses_no_store and uses_cookies) / countif(
        not uses_no_store
    ) as pct_cacheable_set_cookie,
    countif(not uses_no_store and not uses_cookies) / countif(
        not uses_no_store
    ) as pct_cacheable_without_set_cookie,
    countif(not uses_no_store and uses_cookies and uses_private) / countif(
        not uses_no_store and uses_cookies
    ) as pct_pvt_cacheable_set_cookie,
    countif(not uses_no_store and uses_cookies and not uses_private) / countif(
        not uses_no_store and uses_cookies
    ) as pct_pvt_public_cacheable_set_cookie
from
    (
        select
            _table_suffix as client,
            regexp_contains(resp_cache_control, r'(?i)no-store') as uses_no_store,
            regexp_contains(resp_cache_control, r'(?i)private') as uses_private,
            (reqcookielen > 0) as uses_cookies
        from `httparchive.summary_requests.2021_07_01_*`
    )
group by client
