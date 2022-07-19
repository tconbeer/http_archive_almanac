# standardSQL
# Percent of websites using a geolocation library (Based on wappalyzer 'Geolocation'
# category)
# Alternatively, `core_web_vitals.technologies` could be used, but then we do not have
# access to the total number of websites
with
    totals as (
        select _table_suffix, count(distinct url) as total_websites
        from `httparchive.technologies.2021_07_01_*`
        group by _table_suffix
    )

select
    _table_suffix as client,
    app,
    total_websites as total_websites,
    count(distinct url) as number_of_websites,
    count(distinct url) / total_websites as percent_of_websites
from `httparchive.technologies.2021_07_01_*`
join totals using(_table_suffix)
where category = 'Geolocation' and app != ''
group by client, total_websites, app
order by client, number_of_websites desc
