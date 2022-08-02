# standardSQL
# 13_21: Native app links association for ecommerce sites.
# This query uses custom metric 'ecommerce' -
# https://github.com/HTTPArchive/legacy.httparchive.org/blob/master/custom_metrics/ecommerce.js
select
    client,
    countif(android_app_links) as android_app_links,
    countif(ios_universal_links) as ios_universal_links,
    count(0) as total,
    countif(android_app_links) / count(0) as pct_android_app_links,
    countif(ios_universal_links) / count(0) as pct_ios_universal_links
from
    (
        select distinct _table_suffix as client, url
        from `httparchive.technologies.2020_08_01_*`
        where category = 'Ecommerce'
    )
join
    (
        select
            _table_suffix as client,
            url,
            json_extract(
                json_extract_scalar(payload, '$._ecommerce'), '$.AndroidAppLinks'
            )
            = '1' as android_app_links,
            json_extract(
                json_extract_scalar(payload, '$._ecommerce'), '$.iOSUniveralLinks'
            )
            = '1' as ios_universal_links
        from `httparchive.pages.2020_08_01_*`
    ) using (client, url)
group by client
order by client
