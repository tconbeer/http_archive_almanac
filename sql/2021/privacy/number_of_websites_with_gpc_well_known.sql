# standardSQL
# Pages that provide `/.well-known/gpc.json` for Global Privacy Control
with
    totals as (
        select _table_suffix, count(0) as total_websites
        from `httparchive.technologies.2021_07_01_*`
        group by _table_suffix
    )

select
    _table_suffix as client,
    total_websites as total_websites,
    count(0) as number_of_websites,  -- crawled sites containing at least one origin trial
    count(0) / total_websites as percent_of_websites
from `httparchive.pages.2021_07_01_*`
join totals using (_table_suffix)
where json_value(payload, '$._well-known."/.well-known/gpc.json".found') = 'true'
group by client, total_websites
order by client
