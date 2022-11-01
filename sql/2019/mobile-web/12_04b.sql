# standardSQL
# 12_04b: Viewport directive usage
create temporary function getviewportdirectivedata(payload string)
returns array<struct<directive string, value string>>
language js
as
    '''
  var viewport_separator_regex = new RegExp('(,|;| )+', 'gm');

  try {
    var $ = JSON.parse(payload);
    if (!$._meta_viewport) {
      return [];
    }

    var found_directives = new Set();
    var viewport_parts = $._meta_viewport.replace(viewport_separator_regex, ',').split(',');
    return viewport_parts
      .map(function(viewport_part) {
        var [directive, value] = viewport_part.split('=');

        if (found_directives.has(directive)) {
          return false;
        }
        found_directives.add(directive);

        return {
          directive: (directive || '').trim().toLowerCase(),
          value: (value || '').trim().toLowerCase(),
        };
      })
      .filter(v => v !== false);
  } catch (e) {
    return [];
  }
'''
;

select
    total_pages,
    viewport_info.directive as directive,
    viewport_info.value as value,
    sum(count(distinct url)) over (
        partition by viewport_info.directive
    ) as total_sites_with_directive,

    count(0) as total,
    round(
        count(0)
        * 100
        / sum(count(distinct url)) over (partition by viewport_info.directive),
        2
    ) as perc_value_in_directive,
    round(count(0) * 100 / total_pages, 2) as perc_in_all_pages
from
    `httparchive.pages.2019_07_01_mobile`,
    (select count(0) as total_pages from `httparchive.pages.2019_07_01_mobile`),
    unnest(getviewportdirectivedata(payload)) as viewport_info
group by total_pages, viewport_info.directive, viewport_info.value
order by total desc
