# standardSQL
# preload attribute values
select
    client,
    lower(preload_value) as preload_value,
    count(0) as preload_value_count,
    safe_divide(count(0), sum(count(0)) over (partition by client)) as preload_value_pct
from
    `httparchive.almanac.summary_response_bodies`,
    # extract preload attribute value, or empty if none
    unnest(
        regexp_extract_all(body, '<video[^>]*?preload=*(?:"|\')*(.*?)(?:"|\'|\\s|>)')
    ) as preload_value
where date = '2020-08-01' and firsthtml
group by client, preload_value
having preload_value_count > 10
order by client, preload_value_count desc
;
