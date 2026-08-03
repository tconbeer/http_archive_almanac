select
    client,
    case
        when resp_content_type like '%image%'
        then 'images'
        when resp_content_type like '%font%'
        then 'font'
        when resp_content_type like '%css%'
        then 'css'
        when resp_content_type like '%javascript%'
        then 'javascript'
        when resp_content_type like '%json%'
        then 'json'
        else 'other'
    end as content_type,
    count(0) as count,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from `httparchive.almanac.requests`
where date = '2021-07-01'
group by client, content_type
order by pct desc
