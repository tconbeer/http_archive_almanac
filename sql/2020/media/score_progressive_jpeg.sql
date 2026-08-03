# standardSQL
# percent of pages with score_progressive_jpeg
# -1, 0 - 25, 25 - 50, 50 - 75, 75 - 100
select
    client,
    countif(score < 0) / count(0) as percent_negative,
    countif(score >= 0 and score < 25) / count(0) as percent_0_25,
    countif(score >= 25 and score < 50) / count(0) as percent_25_50,
    countif(score >= 50 and score < 75) / count(0) as percent_50_75,
    countif(score >= 75 and score <= 100) / count(0) as percent_75_100
from
    (
        select
            _table_suffix as client,
            cast(json_extract(payload, '$._score_progressive_jpeg') as numeric) as score
        from `httparchive.pages.2020_08_01_*`
    )
group by client
order by client
