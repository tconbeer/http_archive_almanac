# standardSQL
# 14_18b: Lighthouse indexability scores by CMS
select
    app,
    countif(crawlable = '1') as passing,
    count(0) as total,
    round(countif(crawlable = '1') * 100 / count(0), 2) as pct
from `httparchive.technologies.2019_07_01_mobile`
join
    (
        select
            url, json_extract_scalar(report, '$.audits.is-crawlable.score') as crawlable
        from `httparchive.lighthouse.2019_07_01_mobile`
    ) using (url)
where category = 'CMS' and crawlable is not null
group by app
order by total desc
