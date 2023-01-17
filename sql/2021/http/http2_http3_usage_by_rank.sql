# standardSQL
# Percentiles of sites that main page over HTTP/2 or HTTP/3 by rank
select
    client,
    rank_grouping,
    case
        when rank_grouping = 10000000 then 'all' else format("%'d", rank_grouping)
    end as ranking,
    count(0) as freq,
    total,
    count(0) / total as pct
from
    (
        select client, page, rank
        from `httparchive.almanac.requests`
        where
            date = '2021-07-01'
            and firsthtml
            and lower(protocol) in ('http/2', 'http/3', 'quic', 'h3-29', 'h3-q050')
    ),
    unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
join
    (
        select client, rank_grouping, count(0) as total
        from
            `httparchive.almanac.requests`,
            unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where date = '2021-07-01' and rank <= rank_grouping and firsthtml
        group by client, rank_grouping
    ) using (client, rank_grouping)
where rank <= rank_grouping
group by client, total, rank_grouping
order by client, rank_grouping
