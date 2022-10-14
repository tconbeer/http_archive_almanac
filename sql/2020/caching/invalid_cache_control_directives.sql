# standardSQL
# List of invalid Cache-Control directive names.
select
    client,
    total_requests,
    total_using_cache_control,
    directive_name,
    directive_occurrences,
    pct_of_cache_control,
    pct_of_total_requests
from
    (
        (
            select
                'desktop' as client,
                total_requests,
                total_using_cache_control,
                directive_name,
                count(0) as directive_occurrences,
                count(0) / total_using_cache_control as pct_of_cache_control,
                count(0) / total_requests as pct_of_total_requests
            from
                `httparchive.summary_requests.2020_08_01_desktop`,
                unnest(
                    regexp_extract_all(lower(resp_cache_control), r'([a-z][^,\s="\']*)')
                ) as directive_name
            cross join
                (
                    select
                        count(0) as total_requests,
                        countif(
                            trim(resp_cache_control) != ''
                        ) as total_using_cache_control
                    from `httparchive.summary_requests.2020_08_01_desktop`
                )
            group by client, total_requests, total_using_cache_control, directive_name
        )
        union all
        (
            select
                'mobile' as client,
                total_requests,
                total_using_cache_control,
                directive_name,
                count(0) as directive_occurrences,
                count(0) / total_using_cache_control as pct_of_cache_control,
                count(0) / total_requests as pct_of_total_requests
            from
                `httparchive.summary_requests.2020_08_01_mobile`,
                unnest(
                    regexp_extract_all(lower(resp_cache_control), r'([a-z][^,\s="\']*)')
                ) as directive_name
            cross join
                (
                    select
                        count(0) as total_requests,
                        countif(
                            trim(resp_cache_control) != ''
                        ) as total_using_cache_control
                    from `httparchive.summary_requests.2020_08_01_mobile`
                )
            group by client, total_requests, total_using_cache_control, directive_name
        )
    )
where
    directive_name not in (
        'max-age',
        'public',
        'no-cache',
        'must-revalidate',
        'no-store',
        'private',
        'proxy-revalidate',
        's-maxage',
        'no-transform',
        'immutable',
        'stale-while-revalidate',
        'stale-if-error',
        'pre-check',
        'post-check'
    )
order by client, directive_occurrences desc
