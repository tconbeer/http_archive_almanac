# standardSQL
# 04_25: % of pages having WebXR frameworks
select client, framework, count(distinct page) as pages
from
    (
        select
            client,
            page,
            regexp_extract(
                lower(url), '(aframe|babylon|argon)(?:\\.min)?\\.js'
            ) as framework
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and type = 'script'
    )
where framework is not null
group by client, framework
