# standardSQL
# Positive tabindex value occurrences
create temporary function gettotalpositivetabindexes(payload string)
returns struct < total int64,
total_positive int64,
total_negative int64,
total_zero int64
> language js
as '''
try {
  const almanac = JSON.parse(payload);

  let total = 0;
  let total_positive = 0;
  let total_negative = 0;
  let total_zero = 0;
  for (const node of almanac['09.27'].nodes) {
    total++;
    const int = parseInt(node.tabindex, 10);
    if (int > 0) {
      total_positive++;
    } else if (int < 0) {
      total_negative++;
    } else if (int === 0) {
      total_zero++;
    }
  }

  return {total, total_positive, total_negative, total_zero};
} catch (e) {
  return {total: 0, total_positive: 0, total_negative: 0, total_zero: 0};
}
'''
;

select
    client,
    count(0) as total_sites,
    countif(tab_index_stats.total > 0) as total_with_tab_indexes,
    countif(tab_index_stats.total_positive > 0) as total_with_positive_tab_indexes,
    countif(tab_index_stats.total_negative > 0) as total_with_negative_tab_indexes,
    countif(tab_index_stats.total_zero > 0) as total_with_zero_tab_indexes,
    countif(
        tab_index_stats.total_negative > 0 or tab_index_stats.total_zero > 0
    ) as total_with_negative_or_zero,

    countif(tab_index_stats.total > 0) / count(0) as pct_with_tab_indexes,
    countif(tab_index_stats.total_positive > 0) / count(
        0
    ) as pct_with_positive_tab_indexes,
    countif(tab_index_stats.total_positive > 0) / countif(
        tab_index_stats.total > 0
    ) as pct_positive_in_sites_with_tab_indexes
from
    (
        select
            _table_suffix as client,
            gettotalpositivetabindexes(
                json_extract_scalar(payload, '$._almanac')
            ) as tab_index_stats
        from `httparchive.pages.2021_07_01_*`
    )
group by client
