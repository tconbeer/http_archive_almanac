# standardSQL
# Count RDFa Prefixes
create temp function getrdfaprefixes(rendered string)
returns array
< string
> language js as r"""
  try {
    rendered = JSON.parse(rendered);
    const prefixRegExp = new RegExp(/(?<ncname>[^:]*):\s+(?<uri>[^\s]*)\s*/gm)
    return rendered.rdfa_prefixes.map(prefix => {
      const matches = [...prefix.toLowerCase().trim().matchAll(prefixRegExp)];
      return matches.map(match => match.groups.uri);
    }).flat();
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
            getrdfaprefixes(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as rdfa_prefixes
        from `httparchive.pages.2021_07_01_*`
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    rdfa_prefix,
    count(rdfa_prefix) as freq_rdfa,
    sum(count(rdfa_prefix)) over (partition by client) as total_rdfa,
    count(rdfa_prefix) / sum(count(rdfa_prefix)) over (partition by client) as pct_rdfa,
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
                net.reg_domain(rdfa_prefix),
                split(rdfa_prefix, net.reg_domain(rdfa_prefix))[safe_offset(1)]
            ) as rdfa_prefix
        from rendered_data, unnest(rdfa_prefixes) as rdfa_prefix
    )
join page_totals using (client)
group by client, rdfa_prefix, total_pages
order by pct_rdfa desc, client
