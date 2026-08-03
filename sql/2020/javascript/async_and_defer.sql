select
    client,
    count(distinct if(async, page, null)) as async,
    count(distinct if(defer, page, null)) as defer,
    count(distinct if(async and defer, page, null)) as both,
    count(distinct page) as total,
    count(distinct if(async, page, null)) / count(distinct page) as pct_async,
    count(distinct if(defer, page, null)) / count(distinct page) as pct_defer,
    count(distinct if(async and defer, page, null)) / count(distinct page) as pct_both
from
    (
        select
            client,
            page,
            script,
            regexp_contains(script, r'(?i)\basync\b') as async,
            regexp_contains(script, r'(?i)\bdefer\b') as defer
        from `httparchive.almanac.summary_response_bodies`
        left join unnest(regexp_extract_all(body, r'(?i)(<script[^>]*>)')) as script
        where date = '2020-08-01' and firsthtml
    )
group by client
