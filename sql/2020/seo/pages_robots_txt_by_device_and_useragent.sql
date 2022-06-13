# standardSQL
# pages robots_txt metrics grouped by device and status code
# helper to create percent fields
create temp function as_percent(freq float64, total float64) returns float64 as (
    round(safe_divide(freq, total), 4)
)
;

# returns all the data we need from _robots_txt
create temporary function get_robots_txt_info(robots_txt_string string)
returns struct
<
user_agents array
< string
>
> language js
as '''
var result = {
  user_agents: []
};
try {
    var robots_txt = JSON.parse(robots_txt_string);

    if (Array.isArray(robots_txt) || typeof robots_txt != 'object') return result;

    if (robots_txt.user_agents) {
      var uas = robots_txt.user_agents.map(ua => ua.toLowerCase());
      var uas =  uas.filter(function(item, pos) { return uas.indexOf(item) == pos;}); // remove duplicates
      result.user_agents = uas;
    }

} catch (e) {}
return result;
'''
;

select client, user_agent, total, count(0) as count, as_percent(count(0), total) as pct
from
    (
        select
            _table_suffix as client,
            total,
            get_robots_txt_info(
                json_extract_scalar(payload, '$._robots_txt')
            ) as robots_txt_info
        from `httparchive.pages.2020_08_01_*`
        join
            (
                # to get an accurate total of pages per device. also seems fast
                select _table_suffix, count(0) as total
                from `httparchive.pages.2020_08_01_*`
                group by _table_suffix
            )
            using(_table_suffix)
    ),
    unnest(robots_txt_info.user_agents) as user_agent
group by total, user_agent, client
having count >= 100
order by count desc
