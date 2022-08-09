# standardSQL
# Non-cacheable content (no-store present) by resource type
select
    client,
    resource_type,
    count(0) as total_requests,
    countif(not uses_no_store) as total_cacheable,
    countif(uses_no_store) as total_non_cacheable,
    countif(not uses_cache_control and not uses_expires) as total_using_neither,
    countif(not uses_no_store and uses_max_age and exp_age = 0) as total_exp_age_zero,
    countif(
        not uses_no_store and uses_max_age and exp_age > 0
    ) as total_exp_age_gt_zero,
    countif(not uses_no_store) / count(0) as pct_cacheable,
    countif(uses_no_store) / count(0) as pct_non_cacheable,
    countif(not uses_cache_control and not uses_expires)
    / countif(not uses_no_store) as pct_using_neither,
    countif(not uses_no_store and uses_max_age and exp_age = 0)
    / countif(not uses_no_store) as pct_using_exp_age_zero,
    countif(not uses_no_store and uses_max_age and exp_age > 0)
    / countif(not uses_no_store) as pct_using_exp_age_gt_zero
from
    (
        select
            _table_suffix as client,
            type as resource_type,
            trim(resp_cache_control) != '' as uses_cache_control,
            trim(resp_expires) != '' as uses_expires,
            regexp_contains(resp_cache_control, r'(?i)no-store') as uses_no_store,
            regexp_contains(
                resp_cache_control, r'(?i)max-age\s*=\s*[0-9]+'
            ) as uses_max_age,
            expage as exp_age
        from `httparchive.summary_requests.2020_08_01_*`
    )
group by client, resource_type
order by client, resource_type
