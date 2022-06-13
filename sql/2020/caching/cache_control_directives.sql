# standardSQL
# Use of Cache-Control directives
select
    client,
    count(0) as total_requests,
    countif(uses_cache_control) as total_using_cache_control,
    countif(uses_max_age) as total_using_max_age,
    countif(uses_no_cache) as total_using_no_cache,
    countif(uses_public) as total_using_public,
    countif(uses_must_revalidate) as total_using_must_revalidate,
    countif(uses_no_store) as total_using_no_store,
    countif(uses_private) as total_using_private,
    countif(uses_proxy_revalidate) as total_using_proxy_revalidate,
    countif(uses_s_maxage) as total_using_s_maxage,
    countif(uses_no_transform) as total_using_no_transform,
    countif(uses_immutable) as total_using_immutable,
    countif(uses_stale_while_revalidate) as total_using_stale_while_revalidate,
    countif(uses_stale_if_error) as total_using_stale_if_error,
    countif(
        uses_no_store and uses_no_cache and uses_max_age_zero
    ) as total_using_no_store_and_no_cache_and_max_age_zero,
    countif(
        uses_no_store and uses_no_cache and not uses_max_age_zero
    ) as total_using_no_store_and_no_cache_only,
    countif(
        uses_no_store and not uses_no_cache and not uses_max_age_zero
    ) as total_using_no_store_only,
    countif(
        uses_max_age_zero and not uses_no_store
    ) as total_using_max_age_zero_without_no_store,
    countif(
        uses_pre_check_zero and uses_post_check_zero
    ) as total_using_pre_check_zero_and_post_check_zero,
    countif(uses_pre_check_zero) as total_using_pre_check_zero,
    countif(uses_post_check_zero) as total_using_post_check_zero,
    countif(
        uses_cache_control
        and not uses_max_age
        and not uses_no_cache
        and not uses_public
        and not uses_must_revalidate
        and not uses_no_store
        and not uses_private
        and not uses_proxy_revalidate
        and not uses_s_maxage
        and not uses_no_transform
        and not uses_immutable
        and not uses_stale_while_revalidate
        and not uses_stale_if_error
        and not uses_pre_check_zero
        and not uses_post_check_zero
    ) as total_erroneous_directives,
    countif(uses_cache_control) / count(0) as pct_using_cache_control,
    countif(uses_max_age) / count(0) as pct_using_max_age,
    countif(uses_no_cache) / count(0) as pct_using_no_cache,
    countif(uses_public) / count(0) as pct_using_public,
    countif(uses_must_revalidate) / count(0) as pct_using_must_revalidate,
    countif(uses_no_store) / count(0) as pct_using_no_store,
    countif(uses_private) / count(0) as pct_using_private,
    countif(uses_proxy_revalidate) / count(0) as pct_using_proxy_revalidate,
    countif(uses_s_maxage) / count(0) as pct_using_s_maxage,
    countif(uses_no_transform) / count(0) as pct_using_no_transform,
    countif(uses_immutable) / count(0) as pct_using_immutable,
    countif(uses_stale_while_revalidate) / count(0) as pct_using_stale_while_revalidate,
    countif(uses_stale_if_error) / count(0) as pct_using_stale_if_error,
    countif(uses_no_store and uses_no_cache and uses_max_age_zero) / count(
        0
    ) as pct_using_no_store_and_no_cache_and_max_age_zero,
    countif(uses_no_store and uses_no_cache and not uses_max_age_zero) / count(
        0
    ) as pct_using_no_store_and_no_cache_only,
    countif(uses_no_store and not uses_no_cache and not uses_max_age_zero) / count(
        0
    ) as pct_using_no_store_only,
    countif(uses_max_age_zero and not uses_no_store) / count(
        0
    ) as pct_using_max_age_zero_without_no_store,
    countif(uses_pre_check_zero and uses_post_check_zero) / count(
        0
    ) as pct_using_pre_check_zero_and_post_check_zero,
    countif(uses_pre_check_zero) / count(0) as pct_using_pre_check_zero,
    countif(uses_post_check_zero) / count(0) as pct_using_post_check_zero,
    countif(
        uses_cache_control
        and not uses_max_age
        and not uses_no_cache
        and not uses_public
        and not uses_must_revalidate
        and not uses_no_store
        and not uses_private
        and not uses_proxy_revalidate
        and not uses_s_maxage
        and not uses_no_transform
        and not uses_immutable
        and not uses_stale_while_revalidate
        and not uses_stale_if_error
        and not uses_pre_check_zero
        and not uses_post_check_zero
    ) / count(0) as pct_erroneous_directives
from
    (
        select
            _table_suffix as client,
            trim(resp_cache_control) != '' as uses_cache_control,
            regexp_contains(
                resp_cache_control, r'(?i)max-age\s*=\s*[0-9]+'
            ) as uses_max_age,
            regexp_contains(
                resp_cache_control, r'(?i)max-age\s*=\s*0'
            ) as uses_max_age_zero,
            regexp_contains(resp_cache_control, r'(?i)public') as uses_public,
            regexp_contains(resp_cache_control, r'(?i)no-cache') as uses_no_cache,
            regexp_contains(
                resp_cache_control, r'(?i)must-revalidate'
            ) as uses_must_revalidate,
            regexp_contains(resp_cache_control, r'(?i)no-store') as uses_no_store,
            regexp_contains(resp_cache_control, r'(?i)private') as uses_private,
            regexp_contains(
                resp_cache_control, r'(?i)proxy-revalidate'
            ) as uses_proxy_revalidate,
            regexp_contains(
                resp_cache_control, r'(?i)s-maxage\s*=\s*[0-9]+'
            ) as uses_s_maxage,
            regexp_contains(
                resp_cache_control, r'(?i)no-transform'
            ) as uses_no_transform,
            regexp_contains(resp_cache_control, r'(?i)immutable') as uses_immutable,
            regexp_contains(
                resp_cache_control, r'(?i)stale-while-revalidate\s*=\s*[0-9]+'
            ) as uses_stale_while_revalidate,
            regexp_contains(
                resp_cache_control, r'(?i)stale-if-error\s*=\s*[0-9]+'
            ) as uses_stale_if_error,
            regexp_contains(
                resp_cache_control, r'(?i)pre-check\s*=\s*0'
            ) as uses_pre_check_zero,
            regexp_contains(
                resp_cache_control, r'(?i)post-check\s*=\s*0'
            ) as uses_post_check_zero
        from `httparchive.summary_requests.2020_08_01_*`
    )
group by client
