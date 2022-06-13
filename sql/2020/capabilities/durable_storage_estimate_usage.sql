# standardSQL
select
    regexp_replace(yyyymmdd, r'(\d{4})(\d{2})(\d{2})', '\\1_\\2_\\3') as date,
    unix_date(
        cast(regexp_replace(yyyymmdd, r'(\d{4})(\d{2})(\d{2})', '\\1-\\2-\\3') as date)
    ) * 1000 * 60 * 60 * 24 as timestamp,
    client,
    num_urls,
    round(num_urls / total_urls * 100, 5) as percent
from `httparchive.blink_features.usage`
where id = '1371' or feature = 'DurableStorageEstimate'
group by date, timestamp, client, num_urls, total_urls
order by date desc, client, num_urls desc
