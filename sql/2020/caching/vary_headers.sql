# standardSQL
# List of Vary directive names.
select
    client,
    total_requests,
    total_using_vary,
    vary_header,
    occurrences,
    pct_of_vary,
    pct_of_total_requests,
    total_using_both / total_using_vary as pct_of_vary_with_cache_control,
    total_using_vary / total_requests as pct_using_vary
from
    (
        (
            select
                'desktop' as client,
                total_requests,
                total_using_vary,
                total_using_both,
                vary_header,
                count(0) as occurrences,
                count(0) / total_using_vary as pct_of_vary,
                count(0) / total_requests as pct_of_total_requests
            from
                `httparchive.summary_requests.2020_08_01_desktop`,
                unnest(
                    regexp_extract_all(lower(resp_vary), r'([a-z][^,\s="\']*)')
                ) as vary_header
            cross join
                (
                    select
                        count(0) as total_requests,
                        countif(trim(resp_vary) != '') as total_using_vary,
                        countif(
                            trim(resp_vary) != '' and trim(resp_cache_control) != ''
                        ) as total_using_both
                    from `httparchive.summary_requests.2020_08_01_desktop`
                )
            group by
                client, total_requests, total_using_vary, total_using_both, vary_header
        )
        union all
        (
            select
                'mobile' as client,
                total_requests,
                total_using_vary,
                total_using_both,
                vary_header,
                count(0) as occurrences,
                count(0) / total_using_vary as pct_of_vary,
                count(0) / total_requests as pct_of_total_requests
            from
                `httparchive.summary_requests.2020_08_01_mobile`,
                unnest(
                    regexp_extract_all(lower(resp_vary), r'([a-z][^,\s="\']*)')
                ) as vary_header
            cross join
                (
                    select
                        count(0) as total_requests,
                        countif(trim(resp_vary) != '') as total_using_vary,
                        countif(
                            trim(resp_vary) != '' and trim(resp_cache_control) != ''
                        ) as total_using_both
                    from `httparchive.summary_requests.2020_08_01_mobile`
                )
            group by
                client, total_requests, total_using_vary, total_using_both, vary_header
        )
    )
order by client, occurrences desc
