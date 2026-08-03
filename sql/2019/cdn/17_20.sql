# standardSQL
# 17_20: Percentage of responses with s-maxage directive
select
    _table_suffix as client,
    ifnull(nullif(regexp_extract(_cdn_provider, r'^([^,]*).*'), ''), 'ORIGIN') as cdn,
    countif(lower(resp_cache_control) like '%s-maxage%') as freq,
    countif(firsthtml and lower(resp_cache_control) like '%s-maxage%') as firsthtmlfreq,
    countif(
        not firsthtml and lower(resp_cache_control) like '%s-maxage%'
    ) as resourcefreq,
    count(0) as total,
    round(
        countif(lower(resp_cache_control) like '%s-maxage%') * 100 / count(0), 2
    ) as pct,
    round(
        countif(firsthtml and lower(resp_cache_control) like '%s-maxage%')
        * 100
        / count(0),
        2
    ) as firsthtmlpct,
    round(
        countif(not firsthtml and lower(resp_cache_control) like '%s-maxage%')
        * 100
        / count(0),
        2
    ) as resourcepct
from `httparchive.summary_requests.2019_07_01_*`
group by client, cdn
order by client asc, freq desc
