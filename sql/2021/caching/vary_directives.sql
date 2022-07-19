# standardSQL
# List of Vary directive names.
select
    client,
    any_value(total_requests) as total_requests,
    any_value(total_using_vary) as total_using_vary,
    vary_header,
    any_value(occurrences) as occurrences,
    any_value(occurrences) / any_value(total_using_vary) as pct_of_vary,
    any_value(occurrences) / any_value(total_requests) as pct_of_total_requests,
    any_value(total_using_both)
    / any_value(total_using_vary) as pct_of_vary_with_cache_control,
    any_value(total_using_vary) / any_value(total_requests) as pct_using_vary
from
    (
        select
            _table_suffix as client,
            count(0) as total_requests,
            countif(trim(resp_vary) != '') as total_using_vary,
            countif(
                trim(resp_vary) != '' and trim(resp_cache_control) != ''
            ) as total_using_both
        from `httparchive.summary_requests.2021_07_01_*`
        group by client
    )
join
    (
        select _table_suffix as client, vary_header, count(0) as occurrences
        from `httparchive.summary_requests.2021_07_01_*`
        left join
            unnest(
                regexp_extract_all(lower(resp_vary), r'([a-z][^,\s="\']*)')
            ) as vary_header
        group by client, vary_header
    )
    using
    (client)
where vary_header is not null
group by client, vary_header
order by occurrences desc
