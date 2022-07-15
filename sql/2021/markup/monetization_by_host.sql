# standardSQL
# returns the value of the monetization meta node
create temporary function get_almanac_meta_monetization(almanac_string string)
returns string language js
as '''
try {
    const almanac = JSON.parse(almanac_string);
    if (Array.isArray(almanac) || typeof almanac != 'object') return '';

    let nodes = almanac["meta-nodes"]["nodes"];
    nodes = typeof nodes === "string" ? JSON.parse(nodes) : nodes;

    const filteredNode = nodes.filter(n => n.name && n.name.toLowerCase() == "monetization");

    if (filteredNode.length === 0) {
      return "";
    }

    return filteredNode[0].content;
} catch (e) {
  return "";
}
'''
;

select
    client,
    net.host(monetization) as host,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct_ratio
from
    (
        select
            _table_suffix as client,
            get_almanac_meta_monetization(
                json_extract_scalar(payload, '$._almanac')
            ) as monetization
        from `httparchive.pages.2021_07_01_*`
    )
where monetization != ''
group by client, host
order by client, freq desc
