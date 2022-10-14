# standardSQL
# 13_12: Lighthouse indexability scores
select
    json_extract_scalar(report, '$.audits.is-crawlable.score') as crawlable,
    count(0) as freq,
    sum(count(0)) over () as total,
    round(count(0) * 100 / sum(count(0)) over (), 2) as pct
from
    `httparchive.technologies.2019_07_01_mobile`,
    (select count(0) as total from `httparchive.summary_pages.2019_07_01_mobile`)
join `httparchive.lighthouse.2019_07_01_mobile` using (url)
where category = 'Ecommerce'
group by crawlable
order by freq / total desc
