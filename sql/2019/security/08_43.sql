# 08_43: HTTP vs HTTPS
select
    client,
    countif(starts_with(url, 'https://')) as https,
    countif(starts_with(url, 'http://')) as http,
    round( (countif(starts_with(url, 'https://')) / count(0)) * 100, 2) as pct_https,
    round( (countif(starts_with(url, 'http://')) / count(0)) * 100, 2) as pct_http
from `httparchive.almanac.summary_requests`
where date = '2019-07-01'
group by client
