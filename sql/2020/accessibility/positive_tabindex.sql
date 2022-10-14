# standardSQL
# Positive tabindex value occurrences
CREATE TEMPORARY FUNCTION getTotalPositiveTabIndexes(payload STRING)
RETURNS STRUCT<total INT64, total_positive INT64> LANGUAGE js AS '''
try {
  const almanac = JSON.parse(payload);

  let total = 0;
  let total_positive = 0;
  for (const node of almanac['09.27'].nodes) {
    total++;
    if (parseInt(node.tabindex, 10) > 0) {
      total_positive++
    }
  }

  return {total, total_positive};
} catch (e) {
  return {total: 0, total_positive: 0};
}
''';

select
    client,
    count(0) as total_sites,
    countif(tab_index_stats.total > 0) as total_with_tab_indexes,
    countif(tab_index_stats.total_positive > 0) as total_with_positive_tab_indexes,

    countif(tab_index_stats.total > 0) / count(0) as pct_with_tab_indexes,
    countif(tab_index_stats.total_positive > 0)
    / count(0) as pct_with_positive_tab_indexes,
    countif(tab_index_stats.total_positive > 0)
    / countif(tab_index_stats.total > 0) as pct_positive_in_sites_with_tab_indexes
from
    (
        select
            _table_suffix as client,
            gettotalpositivetabindexes(
                json_extract_scalar(payload, '$._almanac')
            ) as tab_index_stats
        from `httparchive.pages.2020_08_01_*`
    )
group by client
