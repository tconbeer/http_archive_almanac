# standardSQL
# M221
# returns all the data we need from _wpt_bodies
create temporary function get_heading_info(wpt_bodies_string string)
returns array < struct < heading string,
total int64
>> language js
as '''
var result = [];
try {
    var wpt_bodies = JSON.parse(wpt_bodies_string);

    if (Array.isArray(wpt_bodies) || typeof wpt_bodies != 'object') return result;

    if (wpt_bodies.headings && wpt_bodies.headings.rendered) {
      ["h1", "h2", "h3", "h4", "h5", "h6", "h7", "h8"].forEach(h => {
        if (wpt_bodies.headings.rendered[h]) result.push({heading: h, total: wpt_bodies.headings.rendered[h].total});
      });
    }
} catch (e) {}
return result;
'''
;

select
    heading,
    percentile,
    client,
    count(distinct url) as total,

    approx_quantiles(total, 1000)[offset(percentile * 10)] as heading_count

from
    (
        select
            _table_suffix as client,
            percentile,
            heading_info.heading as heading,
            heading_info.total as total,
            url
        from
            `httparchive.pages.2020_08_01_*`,
            unnest([10, 25, 50, 75, 90]) as percentile,
            unnest(
                get_heading_info(json_extract_scalar(payload, '$._wpt_bodies'))
            ) as heading_info
    )
group by heading, percentile, client
order by heading, percentile, client
