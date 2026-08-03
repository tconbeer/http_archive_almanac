# standardSQL
# Count RDFa Type Ofs
create temp function getrdfatypeofs(rendered string)
returns array<string>
language js
as
    """
  try {
    rendered = JSON.parse(rendered);
    return rendered.rdfa_typeofs.map(typeOf => typeOf.toLowerCase().trim().split(/\s+/)).flat();
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
            getrdfatypeofs(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as rdfa_type_ofs
        from `httparchive.pages.2021_07_01_*`
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    rdfa_type_of,
    count(rdfa_type_of) as freq_rdfa_type_of,
    sum(count(rdfa_type_of)) over (partition by client) as total_rdfa_type_of,
    count(rdfa_type_of)
    / sum(count(rdfa_type_of)) over (partition by client) as pct_rdfa_type_of,
    count(distinct url) as freq_pages,
    total_pages,
    count(distinct url) / total_pages as pct_pages
from rendered_data, unnest(rdfa_type_ofs) as rdfa_type_of
join page_totals using (client)
group by client, rdfa_type_of, total_pages
order by pct_rdfa_type_of desc, client
