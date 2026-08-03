# standardSQL
# List of invalid Cache-Control directive names.
select
    client,
    total_directives,
    total_using_cache_control,
    directive_name,
    directive_occurrences,
    directive_occurrences / total_using_cache_control as pct_of_cache_control,
    directive_occurrences / total_directives as pct_of_total_directives
from
    (
        select
            _table_suffix as client,
            directive_name,
            count(0) as directive_occurrences,
            sum(count(0)) over (partition by _table_suffix) as total_directives,
            sum(countif(trim(resp_cache_control) != '')) over (
                partition by _table_suffix
            ) as total_using_cache_control
        from `httparchive.summary_requests.2021_07_01_*`
        left join
            unnest(
                regexp_extract_all(lower(resp_cache_control), r'([a-z][^,\s="\']*)')
            ) as directive_name
        group by client, directive_name
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
