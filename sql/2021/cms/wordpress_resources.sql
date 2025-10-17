# standardSQL
# Distribution of WordPress resource types by path
select
    percentile,
    client,
    path,
    approx_quantiles(freq, 1000)[offset(percentile * 10)] as freq
from
    (
        select
            _table_suffix as client,
            page,
            regexp_extract(url, r'/(themes|plugins|wp-includes)/') as path,
            count(0) as freq
        from
            (
                select _table_suffix, url as page
                from `httparchive.technologies.2021_07_01_*`
                where app = 'WordPress'
            )
        join
            (
                select _table_suffix, pageid, url as page
                from `httparchive.summary_pages.2021_07_01_*`
            ) using (_table_suffix, page)
        join
            (
                select _table_suffix, pageid, url
                from `httparchive.summary_requests.2021_07_01_*`
            ) using (_table_suffix, pageid)
        group by client, page, path
        having path is not null
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client, path
order by percentile, client, path
