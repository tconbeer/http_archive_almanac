# standardSQL
# Count RDFa Vocabs
create temp function getrdfavocabs(rendered string)
returns array
< string
>
language js
as """
  try {
    rendered = JSON.parse(rendered);
    return rendered.rdfa_vocabs.map(vocab => vocab.toLowerCase());
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
            getrdfavocabs(
                json_extract(
                    json_value(json_extract(payload, '$._structured-data')),
                    '$.structured_data.rendered'
                )
            ) as rdfa_vocabs
        from `httparchive.pages.2021_07_01_*`
    ),

    page_totals as (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    rdfa_vocab,
    count(rdfa_vocab) as freq_rdfa_vocab,
    sum(count(rdfa_vocab)) over (partition by client) as total_rdfa_vocab,
    count(rdfa_vocab) / sum(
        count(rdfa_vocab)
    ) over (partition by client) as pct_rdfa_vocab,
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
                net.reg_domain(rdfa_vocab),
                split(rdfa_vocab, net.reg_domain(rdfa_vocab)) [safe_offset(1)]
            ) as rdfa_vocab
        from rendered_data, unnest(rdfa_vocabs) as rdfa_vocab
    )
join page_totals using(client)
group by client, rdfa_vocab, total_pages
order by pct_pages desc, client
