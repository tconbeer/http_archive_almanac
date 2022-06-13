# standardSQL
# Average Percent per page of external scripts using Async, Defer, Module or NoModule
# attributes.
select
    client,
    avg(pct_external_async) as avg_pct_external_async,
    avg(pct_external_defer) as avg_pct_external_defer,
    avg(pct_external_module) as avg_pct_external_module,
    avg(pct_external_nomodule) as avg_pct_external_nomodule
from
    (
        select
            client,
            page,
            count(0) as external_scripts,
            countif(regexp_contains(script, r'\basync\b')) / count(
                0
            ) as pct_external_async,
            countif(regexp_contains(script, r'\bdefer\b')) / count(
                0
            ) as pct_external_defer,
            countif(regexp_contains(script, r'\bmodule\b')) / count(
                0
            ) as pct_external_module,
            countif(regexp_contains(script, r'\bnomodule\b')) / count(
                0
            ) as pct_external_nomodule
        from
            (
                select
                    client,
                    page,
                    url,
                    regexp_extract_all(body, '(?i)(<script [^>]*)') as scripts
                from `httparchive.almanac.summary_response_bodies`
                where date = '2020-08-01' and firsthtml
            ),
            unnest(scripts) as script
        where regexp_contains(script, r'\bsrc\b')
        group by client, page
    )
group by client
