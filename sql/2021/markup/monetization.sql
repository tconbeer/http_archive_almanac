# standardSQL
# returns the value of the monetization meta node
select
    yyyymmdd,
    client,
    countif(feature = 'HTMLMetaElementMonetization') as meta,
    countif(feature = 'HTMLLinkElementMonetization') as link,
    countif(
        feature in ('HTMLMetaElementMonetization', 'HTMLLinkElementMonetization')
    ) as either,
    count(distinct url) as total,
    countif(feature = 'HTMLMetaElementMonetization') / count(distinct url) as meta_pct,
    countif(feature = 'HTMLLinkElementMonetization') / count(distinct url) as link_pct,
    countif(
        feature in ('HTMLMetaElementMonetization', 'HTMLLinkElementMonetization')
    ) / count(distinct url) as either_pct
from `httparchive.blink_features.features`
where yyyymmdd = '2021-07-01'
group by yyyymmdd, client
order by client, either desc
