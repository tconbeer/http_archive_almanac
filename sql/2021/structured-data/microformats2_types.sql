# standardSQL
# Count microformats2 types
create temp function getmicroformats2types(rendered string)
returns array < struct < name string,
count numeric
>>
language js
as """
  try {
    rendered = JSON.parse(rendered);
    return rendered.microformats2_types.map(microformat2_type => ({name: microformat2_type.name, count: microformat2_type.count}));
  } catch (e) {
    return [];
  }
"""
;

with
    rendered_data as (
        select
            _table_suffix as client,
            url,
            getmicroformats2types(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as microformats2_types
        from `httparchive.pages.2021_07_01_*`
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    microformats2_type.name as microformats2_type,
    sum(microformats2_type.count) as freq_microformats2,
    sum(sum(microformats2_type.count)) over (
        partition by client
    ) as total_microformats2_type,
    sum(microformats2_type.count) / sum(
        sum(microformats2_type.count)
    ) over (partition by client) as pct_microformats2_type,
    count(distinct url) as freq_pages,
    total_pages,
    count(distinct url) / total_pages as pct_pages
from rendered_data, unnest(microformats2_types) as microformats2_type
join page_totals using(client)
group by client, microformats2_type, total_pages
order by pct_microformats2_type desc, client
