# standardSQL
# Percent of websites using a specific CMP (Based on wappalyzer 'Cookie compliance'
# category)
# Alternatively, `core_web_vitals.technologies` could be used, but then we do not have
# access to the total number of websites
# Note: we did not use the results of this query in 2021, since Wappalyzer
# definitions/detections
# were unreliable. (https://github.com/HTTPArchive/almanac.httparchive.org/issues/2292)
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
join totals using (_table_suffix)
where category = 'Cookie compliance' and app != ''
group by client, total_websites, app
order by client, number_of_websites desc
