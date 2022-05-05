# standardSQL
# Payment request api usage on ecommerce pages
select
    client,
    count(0) as total_ecommerce,
    countif(uses_payment_requst) as total_using_payment_request,

    countif(uses_payment_requst) / count(0) as pct_using_payment_request
from
    (
        select _table_suffix as client, url
        from `httparchive.technologies.2021_07_01_*`
        where category = 'Ecommerce'
    )
left outer join
    (
        select client, url, true as uses_payment_requst
        from `httparchive.blink_features.features`
        where
            yyyymmdd = cast('2021-07-01' as date) and
            feature = 'PaymentRequestInitialized'
    )
    using(client, url)
group by client
