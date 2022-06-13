# standardSQL
# Percent of websites with any privacy-related service, based on wappalyzer categories
# Cannot use `core_web_vitals.technologies`, as we cannot take the `OR` of websites
select
    _table_suffix as client,
    count(distinct url) as total_pages,
    count(
        distinct if(category = 'Cookie compliance', url, null)
    ) as number_of_websites_with_cookie_compliance,
    count(distinct if(category = 'Cookie compliance', url, null)) / count(
        distinct url
    ) as pct_websites_with_cookie_compliance,
    count(
        distinct if(category = 'Browser fingerprinting', url, null)
    ) as number_of_websites_with_browser_fingerprinting,
    count(distinct if(category = 'Browser fingerprinting', url, null)) / count(
        distinct url
    ) as pct_websites_with_browser_fingerprinting,
    count(
        distinct if(category = 'Retargeting', url, null)
    ) as number_of_websites_with_retargeting,
    count(distinct if(category = 'Retargeting', url, null)) / count(
        distinct url
    ) as pct_websites_with_retargeting,
    count(
        distinct if(category = 'Geolocation', url, null)
    ) as number_of_websites_with_geolocation,
    count(distinct if(category = 'Geolocation', url, null)) / count(
        distinct url
    ) as pct_websites_with_geolocation
from `httparchive.technologies.2021_07_01_*`
group by client
order by client
