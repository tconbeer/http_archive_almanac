# standardSQL
# Distribution of Percent per page of external scripts using Async, Defer, Module or
# NoModule attributes.
select
    percentile,
    client,
    approx_quantiles(pct_external_async, 1000)[
        offset(percentile * 10)
    ] as pct_external_async,
    approx_quantiles(pct_external_defer, 1000)[
        offset(percentile * 10)
    ] as pct_external_defer,
    approx_quantiles(pct_external_module, 1000)[
        offset(percentile * 10)
    ] as pct_external_module,
    approx_quantiles(pct_external_nomodule, 1000)[
        offset(percentile * 10)
    ] as pct_external_nomodule
from
    (
        select
            client,
            page,
            count(0) as external_scripts,
            sum(if(script like '%async%', 1, 0)) as async,
            sum(if(script like '%defer%', 1, 0)) as defer,
            sum(if(script like '%module%', 1, 0)) as module,
            sum(if(script like '%nomodule%', 1, 0)) as nomodule,
            sum(if(script like '%async%', 1, 0)) / count(0) as pct_external_async,
            sum(if(script like '%defer%', 1, 0)) / count(0) as pct_external_defer,
            sum(if(script like '%module%', 1, 0)) / count(0) as pct_external_module,
            sum(if(script like '%nomodule%', 1, 0)) / count(0) as pct_external_nomodule
        from
            (
                select
                    client,
                    page,
                    url,
                    regexp_extract_all(lower(body), '(<script [^>]*)') as scripts
                from `httparchive.almanac.summary_response_bodies`
                where date = '2020-08-01' and firsthtml
            )
        cross join unnest(scripts) as script
        where script like '%src%'
        group by client, page
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
