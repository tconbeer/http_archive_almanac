# standardSQL
# Count Microdata item types
create temp function getmicrodataitemtypes(rendered string)
returns array
< string
> language js as """
  try {
    rendered = JSON.parse(rendered);
    return rendered.microdata_itemtypes.map(itemType => itemType.toLowerCase());
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
            getmicrodataitemtypes(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as microdata_item_types
        from `httparchive.pages.2021_07_01_*`
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    microdata_item_type,
    count(microdata_item_type) as freq_microdata,
    sum(count(microdata_item_type)) over (partition by client) as total_microdata,
    count(microdata_item_type)
    / sum(count(microdata_item_type)) over (partition by client) as pct_microdata,
    count(distinct url) as freq_pages,
    total_pages,
    count(distinct url) / total_pages as pct_pages
from
    (
        select
            client,
            url,
            -- Removes the protocol and any subdomains from the URL.
            -- e.g. "https://my.example.com/pathname" becomes "example.com/pathname"
            -- This is done to normalize the URL a bit before counting.
            concat(
                net.reg_domain(microdata_item_type),
                split(
                    microdata_item_type,
                    net.reg_domain(microdata_item_type)
                ) [safe_offset(1)
                ]
            ) as microdata_item_type
        from rendered_data, unnest(microdata_item_types) as microdata_item_type
    )
join page_totals using(client)
group by client, microdata_item_type, total_pages
order by freq_microdata desc, client
