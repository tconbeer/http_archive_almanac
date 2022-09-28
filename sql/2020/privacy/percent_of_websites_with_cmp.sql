# standardSQL
# Percent of websites with CMP
with
    base as (
        select
            _table_suffix as client,
            url,
            logical_or(category = 'Cookie compliance') as with_cmp
        from `httparchive.technologies.2020_08_01_*`
        group by client, url
    )

select
    client,
    count(url) as total_pages,
    countif(with_cmp) / count(url) as pct_websites_with_cmp
from base
group by client
