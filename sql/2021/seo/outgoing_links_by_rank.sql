# standardSQL
# Internal and external link metrics by quantile and rank
create temporary function getoutgoinglinkmetrics(payload string)
returns struct<same_site int64, same_property int64, other_property int64>
language js
as '''
var result = {same_site: 0,
              same_property: 0,
              other_property: 0};

try {
    var $ = JSON.parse(payload);
    var wpt_bodies  = JSON.parse($._wpt_bodies);

    if (!wpt_bodies){
        return result;
    }

    var anchors = wpt_bodies.anchors;

    if (anchors){
      result.same_site = anchors.rendered.same_site;
      result.same_property = anchors.rendered.same_property;
      result.other_property = anchors.rendered.other_property;
    }

} catch (e) {}

return result;
'''
;

select
    client,
    percentile,
    rank_grouping,
    count(distinct page) as pages,
    approx_quantiles(outgoing_link_metrics.same_site, 1000)[
        offset(percentile * 10)
    ] as outgoing_links_same_site,
    approx_quantiles(outgoing_link_metrics.same_property, 1000)[
        offset(percentile * 10)
    ] as outgoing_links_same_property,
    approx_quantiles(outgoing_link_metrics.other_property, 1000)[
        offset(percentile * 10)
    ] as outgoing_links_other_property
from
    (
        select
            _table_suffix as client,
            url as page,
            getoutgoinglinkmetrics(payload) as outgoing_link_metrics
        from `httparchive.pages.2021_07_01_*`
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
left join
    (
        select _table_suffix as client, url as page, rank
        from `httparchive.summary_pages.2021_07_01_*`
    ) using (client, page),
    unnest([1 e3, 1 e4, 1 e5, 1 e6, 1 e7]) as rank_grouping
where rank <= rank_grouping
group by client, rank_grouping, percentile
order by client, rank_grouping, percentile
