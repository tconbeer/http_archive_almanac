# standardSQL
# 09_28: Pages that auto refresh, e.g. http-equiv="refresh" attribute in the meta tag
create temporary function gettotalmetarefresh(payload string)
returns int64
language js
as '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    if (!almanac['meta-nodes']) {
      return 0;
    }

    return almanac['meta-nodes'].reduce(function(acc, node) {
      if (!node['http-equiv']) {
        return acc;
      }

      if (node['http-equiv'].toLowerCase() === 'refresh') {
        return acc + 1;
      }

      return acc;
    }, 0);
  } catch (e) {
    return 0;
  }
'''
;

select
    client,
    countif(total_matches > 0) as occurrences,
    total_pages,
    round(countif(total_matches > 0) * 100 / total_pages, 2) as occurrence_percentage
from
    (
        select
            _table_suffix as client, url, gettotalmetarefresh(payload) as total_matches
        from `httparchive.pages.2019_07_01_*`
    )
join
    (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (client)
group by client, total_pages
order by occurrences desc
