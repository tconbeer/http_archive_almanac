# standardSQL
# 17_18: Percentage of responses that were pushed
select
    client,
    cdn,
    countif(pushed) as freq,
    count(0) as total,
    round(countif(pushed) * 100 / count(0), 2) as pct
from
    (
        select
            client,
            _cdn_provider as cdn,
            json_extract(payload, '$._was_pushed') is not null as pushed
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
    )
group by client, cdn
order by total desc
