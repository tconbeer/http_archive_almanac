# standardSQL
# 17_10b: Common vary headers as seen from CDNs
select
    client,
    firsthtml,
    vary,
    if(_cdn_provider != '', 'CDN', 'Origin') as source,
    count(0) as total
from
    `httparchive.almanac.requests`,
    unnest(
        split(
            regexp_replace(
                regexp_replace(lower(resp_vary), '"', ''), '[, ]+|\\\\0', ','
            ),
            ','
        )
    ) as vary
where date = '2019-07-01'
group by client, firsthtml, vary, source
having vary != '' and vary is not null
order by client desc, firsthtml desc, total desc
