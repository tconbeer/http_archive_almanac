# standardSQL
# This query uses custom metric '_well-known' -
# https://github.com/HTTPArchive/legacy.httparchive.org/blob/master/custom_metrics/well-known.js
# Note that in this query, there is a subtle bug where the site could have empty
# /.well-known/assetlinks.json or /.well-known/apple-app-site-association files which
# will lead to over counting sites with native app links
# an example is: https://www.allbirds.com/.well-known/assetlinks.json which has a
# payload of "[]"
# To fix this, this would require response body parsing on well-known.js
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
        from `httparchive.technologies.2021_07_01_*`
        where
            category = 'Ecommerce' and (
                app != 'Cart Functionality'
                and app != 'Google Analytics Enhanced eCommerce'
            )
    )
join
    (
        select
            _table_suffix as client,
            url,
            json_value(
                json_extract_scalar(payload, '$._well-known'),
                '$."/.well-known/assetlinks.json".found'
            ) = 'true' as android_app_links,
            json_value(
                json_extract_scalar(payload, '$._well-known'),
                '$."/.well-known/apple-app-site-association".found'
            ) = 'true' as ios_universal_links
        from `httparchive.pages.2021_07_01_*`
    )
    using
    (client, url)
group by client
order by client
