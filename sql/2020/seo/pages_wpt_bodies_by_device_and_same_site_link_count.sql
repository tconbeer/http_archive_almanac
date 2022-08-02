# standardSQL
# page wpt_bodies metrics grouped by device and number of same_site links
# this query aims to highlight sites with few same site links, like SPAs
# helper to create percent fields
create temp function as_percent(freq float64, total float64) returns float64 as (
    round(safe_divide(freq, total), 4)
)
;

# returns all the data we need from _wpt_bodies
create temporary function get_wpt_bodies_info(wpt_bodies_string string)
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

    as_percent(count(0), total) as pct_links_same_site,

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
            get_wpt_bodies_info(
                json_extract_scalar(payload, '$._wpt_bodies')
            ) as wpt_bodies_info
        from `httparchive.pages.2020_08_01_*`
        join
            (
                # to get an accurate total of pages per device. also seems fast
                select _table_suffix, count(0) as total
                from `httparchive.pages.2020_08_01_*`
                group by _table_suffix
            ) using (_table_suffix)
    )
group by client, links_same_site, total
order by links_same_site asc
limit 100
