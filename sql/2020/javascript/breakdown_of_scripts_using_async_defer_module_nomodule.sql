# standardSQL
# Breakdown of scripts using Async, Defer, Module or NoModule attributes.  Also
# breakdown of inline vs external scripts
select
    client,
    count(0) as total_scripts,
    sum(if(script not like '%src%', 1, 0)) as inline_script,
    sum(if(script like '%src%', 1, 0)) as external_script,
    sum(if(script like '%src%', 1, 0)) / count(0) as pct_external_script,
    sum(if(script not like '%src%', 1, 0)) / count(0) as pct_inline_script,
    sum(if(script like '%async%', 1, 0)) as async,
    sum(if(script like '%defer%', 1, 0)) as defer,
    sum(if(script like '%module%', 1, 0)) as module,
    sum(if(script like '%nomodule%', 1, 0)) as nomodule,
    sum(if(script like '%async%', 1, 0)) / sum(
        if(script like '%src%', 1, 0)
    ) as pct_external_async,
    sum(if(script like '%defer%', 1, 0)) / sum(
        if(script like '%src%', 1, 0)
    ) as pct_external_defer,
    sum(if(script like '%module%', 1, 0)) / sum(
        if(script like '%src%', 1, 0)
    ) as pct_external_module,
    sum(if(script like '%nomodule%', 1, 0)) / sum(
        if(script like '%src%', 1, 0)
    ) as pct_external_nomodule
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
group by client
