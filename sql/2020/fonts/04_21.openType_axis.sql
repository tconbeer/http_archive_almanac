# standardSQL
# OpenType axis
create temp function getaxes(font_details string)
returns array<string>
language js
as '''
try {
  return Object.keys(JSON.parse(font_details).table_sizes);
} catch (e) {
  return [];
}
'''
;
select
    client,
    axis,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total_freq,
    count(0) / sum(count(0)) over (partition by client) as pct_freq
from
    (
        select client, page, axis
        from
            `httparchive.almanac.requests`,
            unnest(getaxes(json_extract(payload, '$._font_details'))) as axis
        where date = '2020-09-01' and type = 'font'
    )
group by client, axis
order by pct_freq desc
