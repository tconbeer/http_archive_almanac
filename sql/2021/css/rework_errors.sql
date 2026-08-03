# standardSQL
select
    client,
    parsed_stylesheets,
    total_stylesheets,
    parsed_stylesheets / total_stylesheets as pct_parsed
from
    (
        select client, count(0) as total_stylesheets
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and type = 'css'
        group by client
    )
join
    (
        select client, count(0) as parsed_stylesheets
        from `httparchive.almanac.parsed_css`
        where date = '2021-07-01' and url != 'inline'
        group by client
    ) using (client)
