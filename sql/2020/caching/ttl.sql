# standardSQL
# TTL statistics for cacheable content (no-store absent)
select
    client,
    count(0) as total_requests,
    countif(not uses_cache_control and not uses_expires) as total_using_neither,
    countif(not uses_no_store and uses_max_age and exp_age = 0) as total_exp_age_zero,
    countif(
        not uses_no_store and uses_max_age and exp_age > 0
    ) as total_exp_age_gt_zero,
    countif(uses_no_store) as total_not_cacheable,
    countif(not uses_no_store) as total_cacheable,
    countif(not uses_cache_control and not uses_expires)
    / countif(not uses_no_store) as pct_using_neither,
    countif(not uses_no_store and uses_max_age and exp_age = 0)
    / countif(not uses_no_store) as pct_using_exp_age_zero,
    countif(not uses_no_store and uses_max_age and exp_age > 0)
    / countif(not uses_no_store) as pct_using_exp_age_gt_zero,
    countif(uses_no_store) / count(0) as pct_not_cacheable,
    countif(not uses_no_store) / count(0) as pct_cacheable
from
    (
        select
            _table_suffix as client,
            trim(resp_cache_control) != '' as uses_cache_control,
            trim(resp_expires) != '' as uses_expires,
            regexp_contains(resp_cache_control, r'(?i)no-store') as uses_no_store,
            regexp_contains(
                resp_cache_control, r'(?i)max-age\s*=\s*[0-9]+'
            ) as uses_max_age,
            expage as exp_age
        from `httparchive.summary_requests.2020_08_01_*`
    )
group by client
