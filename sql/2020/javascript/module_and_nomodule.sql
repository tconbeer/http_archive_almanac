select
    client,
    count(distinct if(module, page, null)) as module,
    count(distinct if(nomodule, page, null)) as nomodule,
    count(distinct if(nomodule and module, page, null)) as both,
    count(distinct page) as total,
    count(distinct if(module, page, null)) / count(distinct page) as pct_module,
    count(distinct if(nomodule, page, null)) / count(distinct page) as pct_nomodule,
    count(distinct if(module and nomodule, page, null)) / count(
        distinct page
    ) as pct_both
from
    (
        select
            client,
            page,
            script,
            regexp_contains(script, r'(?i)\bmodule\b') as module,
            regexp_contains(script, r'(?i)\bnomodule\b') as nomodule
        from `httparchive.almanac.summary_response_bodies`
        left join unnest(regexp_extract_all(body, r'(?i)(<script[^>]*>)')) as script
        where date = '2020-08-01' and firsthtml
    )
group by client
