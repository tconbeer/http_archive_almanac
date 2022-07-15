# standardSQL
# page robots_txt metrics grouped by device and status code
# helper to create percent fields
create temp function as_percent(freq float64, total float64) returns float64 as (
    round(safe_divide(freq, total), 4)
)
;

# returns all the data we need from _robots_txt
create temporary function get_robots_txt_info(robots_txt_string string)
returns struct
< status_code string
> language js as '''
var result = {};
try {
    var robots_txt = JSON.parse(robots_txt_string);

    if (Array.isArray(robots_txt) || typeof robots_txt != 'object') return result;

    if (robots_txt.status) {
      result.status_code = ''+robots_txt.status;
    }

} catch (e) {}
return result;
'''
;

select
    client,
    robots_txt_info.status_code as status_code,

    count(0) as total,

    as_percent(count(0), sum(count(0)) over (partition by client)) as pct

from
    (
        select
            _table_suffix as client,
            get_robots_txt_info(
                json_extract_scalar(payload, '$._robots_txt')
            ) as robots_txt_info
        from `httparchive.pages.2020_08_01_*`
    )
group by client, status_code
order by total desc
