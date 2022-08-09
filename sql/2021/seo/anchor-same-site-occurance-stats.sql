# standardSQL
# Anchor same site occurance stats
# this query aims to highlight sites with few same site links, like SPAs
# TODO: this query may tell a better story if we use quantiles for links_same_site as
# that would allow us to truly compare low-a-linking sites verse high-a-linking sites.
create temporary function getlinkdesciptionswptbodies(wpt_bodies_string string)
returns struct < links_same_site int64,
links_window_location int64,
links_window_open int64,
links_href_javascript int64

> language js
as '''
var result = {};
try {
  var wpt_bodies = JSON.parse(wpt_bodies_string);

  if (Array.isArray(wpt_bodies) || typeof wpt_bodies != 'object') return result;

  if (wpt_bodies.anchors && wpt_bodies.anchors.rendered) {
      var anchors_rendered = wpt_bodies.anchors.rendered;

      result.links_same_site = anchors_rendered.same_site;
      result.links_window_location = anchors_rendered.same_page.dynamic.onclick_attributes.window_location;
      result.links_window_open = anchors_rendered.same_page.dynamic.onclick_attributes.window_open;
      result.links_href_javascript = anchors_rendered.same_page.dynamic.href_javascript;

    }

} catch (e) {}
return result;
'''
;

select
    client,

    wpt_bodies_info.links_same_site as links_same_site,

    count(0) as pages,

    safe_divide(count(0), total) as pct_links_same_site,

    avg(wpt_bodies_info.links_window_location) as avg_links_window_location,
    avg(wpt_bodies_info.links_window_open) as avg_links_window_open,
    avg(wpt_bodies_info.links_href_javascript) as avg_links_href_javascript,
    avg(
        wpt_bodies_info.links_window_location
        + wpt_bodies_info.links_window_open
        + wpt_bodies_info.links_href_javascript
    ) as avg_links_any,
    max(
        wpt_bodies_info.links_window_location
        + wpt_bodies_info.links_window_open
        + wpt_bodies_info.links_href_javascript
    ) as max_links_any
from
    (
        select
            _table_suffix as client,
            total,
            getlinkdesciptionswptbodies(
                json_extract_scalar(payload, '$._wpt_bodies')
            ) as wpt_bodies_info
        from `httparchive.pages.2021_07_01_*`
        join
            (

                select _table_suffix, count(0) as total
                from `httparchive.pages.2021_07_01_*`
                group by _table_suffix
            ) using (_table_suffix)
    )
group by client, links_same_site, total
order by links_same_site asc
limit 100
