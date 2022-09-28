# standardSQL
# Captcha usage
select
    client,
    total_sites,
    sites_with_captcha,
    sites_with_captcha / total_sites as perc_sites_with_captcha
from
    (
        select _table_suffix as client, count(distinct url) as sites_with_captcha
        from `httparchive.technologies.2021_07_01_*`
        where app = 'reCAPTCHA' or app = 'hCaptcha'
        group by client
    )
join
    (
        select _table_suffix as client, count(0) as total_sites
        from `httparchive.summary_pages.2021_07_01_*`
        group by client
    ) using (client)
