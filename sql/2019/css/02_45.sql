# standardSQL
# 02_45: Distribution of classes per element
select
    client,
    approx_quantiles(classes, 1000) [offset (100)] as p10,
    approx_quantiles(classes, 1000) [offset (250)] as p25,
    approx_quantiles(classes, 1000) [offset (500)] as p50,
    approx_quantiles(classes, 1000) [offset (750)] as p75,
    approx_quantiles(classes, 1000) [offset (900)] as p90
from
    (
        select client, array_length(split(value, ' ')) as classes
        from
            `httparchive.almanac.summary_response_bodies`,
            unnest(regexp_extract_all(body, '(?i)class=[\'"]([^\'"]+)')) as value
        where date = '2019-07-01' and firsthtml
    )
group by client
