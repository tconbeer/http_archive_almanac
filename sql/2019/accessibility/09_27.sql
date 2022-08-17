# standardSQL
# 09_27: Sites with elements that are in the tab order but have no interactive role,
# e.g. a paragraph
create temporary function gettagswithtabindex(payload string)
returns array
< string
> language js as '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    if (!almanac['09.27']) {
      return [];
    }

    var interactive_elements =
        ['a', 'audio', 'button', 'details', 'input', 'select', 'textarea', 'video'];

    return almanac['09.27']
      .map(function(node) {
        var tabindex_value = parseInt(node.tabindex, 10);
        if (isNaN(tabindex_value) || tabindex_value < 0) {
          return null;
        }

        var name = node.tagName.toLowerCase();
        return interactive_elements.indexOf(name) < 0 ? name : null;
      })
      .filter(name => name)
  } catch (e) {
    return [];
  }
'''
;

select
    _table_suffix as client,
    tag_type,
    count(tag_type) as occurrences,
    sum(count(0)) over (partition by _table_suffix) as total_interactive_elements,
    round(
        count(tag_type) * 100 / sum(count(0)) over (partition by _table_suffix), 2
    ) as occurrence_perc,
    count(distinct url) as pages,
    total as total_pages,
    round(count(distinct url) * 100 / total, 2) as pages_perc
from `httparchive.pages.2019_07_01_*`, unnest(gettagswithtabindex(payload)) as tag_type
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (_table_suffix)
group by client, tag_type, total
order by occurrences desc
