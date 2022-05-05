# standardSQL
# cdn_usage_by_site_rank.sql : Distribution of HTML pages served by CDN vs Origin by
# rank
select
    client,
    nested_rank,
    cdn,
    count(0) as num_requests,
    sum(count(0)) over (partition by client, nested_rank) as total,
    count(0) / sum(count(0)) over (partition by client, nested_rank) as pct_requests
from
    (
        select
            client,
            if(
                ifnull(
                    nullif(regexp_extract(_cdn_provider, r'^([^,]*).*'), ''), 'ORIGIN'
                ) = 'ORIGIN',
                'ORIGIN',
                'CDN'
            ) as cdn,
            rank
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and firsthtml and rank is not null
    ),
    unnest( [1000, 10000, 100000, 1000000, 10000000]) as nested_rank
where rank <= nested_rank
group by client, cdn, nested_rank
order by client, nested_rank, cdn
