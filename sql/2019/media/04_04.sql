# standardSQL
# 04_04: Inline SVGs
select
    percentile,
    client,
    approx_quantiles(svg_elements, 1000)[offset(percentile * 10)] as svg_elements,
    approx_quantiles(svg_length, 1000)[offset(percentile * 10)] as svg_length
from
    (
        select client, count(svg) as svg_elements, sum(length(svg)) as svg_length
        from
            `httparchive.almanac.summary_response_bodies`,
            unnest(regexp_extract_all(body, r'(?i)(<svg.*?/svg>)')) as svg
        where date = '2019-07-01' and firsthtml
        group by client, page
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
