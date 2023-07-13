# standardSQL
# 04_08: Pages with <picture><img></picture>
select
    client,
    countif(has_picture_img) as has_picture_img,
    count(0) as total,
    round(countif(has_picture_img) * 100 / count(0), 2) as pct
from
    (
        select
            client,
            regexp_contains(
                body, r'(?si)<picture.*?<img.*?/picture>'
            ) as has_picture_img
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
group by client
order by client desc
