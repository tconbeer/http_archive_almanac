# standardSQL
# 09_05b: % of sites using ARIA role
select
    client,
    count(0) as total_sites,
    countif(uses_roles) as total_using_roles,
    round(countif(uses_roles) * 100 / count(0), 2) as perc_using_roles
from
    (
        select client, regexp_contains(body, r'role=[\'"]?([\w-]+)') as uses_roles
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
group by client
