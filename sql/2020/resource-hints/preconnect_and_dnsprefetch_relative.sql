# standardSQL
# Pages that combine preconnect and dns-prefetch hints divided by pages with either
# hint.
CREATE TEMPORARY FUNCTION preconnectsAndPrefetchesDns(payload STRING)
RETURNS STRUCT<both BOOLEAN, either BOOLEAN> LANGUAGE js AS '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['link-nodes'].nodes.reduce((obj, node) => {
    var rel = node.rel.toLowerCase();
    if (rel.includes("preconnect") && rel.includes("dns-prefetch")) {
      obj.both = true;
    }
    if (rel.includes("preconnect") || rel.includes("dns-prefetch")) {
      obj.either = true;
    }
    return obj;
  }, {});
} catch (e) {
  return {};
}
''';

select
    client,
    countif(hint.both) as freq_both,
    countif(hint.either) as total_either,
    countif(hint.both) / countif(hint.either) as pct_both
from
    (
        select _table_suffix as client, preconnectsandprefetchesdns(payload) as hint
        from `httparchive.pages.2020_08_01_*`
    )
group by client
