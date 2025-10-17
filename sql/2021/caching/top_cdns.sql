# standardSQL
# Adoption of top CDNs
select client, cdn, count(0) as freq, total, count(0) / total as pct
from
    (
        select
            _table_suffix as client,
            count(0) as total,
            array_concat_agg(split(cdn, ', ')) as cdn_list
        from `httparchive.summary_pages.2021_07_01_*`
        group by client
    ),
    unnest(cdn_list) as cdn
group by client, cdn, total
order by pct desc
