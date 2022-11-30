# standardSQL
# Adoption of SW by CrUX rank
select
    client,
    rank_magnitude as rank,
    count(distinct if(feature = 'ServiceWorkerControlledPage', url, null)) as sw_pages,
    count(distinct url) as total,
    count(distinct if(feature = 'ServiceWorkerControlledPage', url, null))
    / count(distinct url) as pct
from
    `httparchive.blink_features.features`,
    unnest([1e3, 1e4, 1e5, 1e6, 1e7]) as rank_magnitude
where yyyymmdd = '2021-07-01' and rank <= rank_magnitude
group by client, rank
order by rank, client
