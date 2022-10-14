# standardSQL
# Robots txt status codes
# returns all the data we need from _robots_txt
CREATE TEMPORARY FUNCTION getRobotsStatusInfo(robots_txt_string STRING)
RETURNS STRUCT<
  status_code STRING
> LANGUAGE js AS '''
var result = {};
try {
    var robots_txt = JSON.parse(robots_txt_string);

    if (Array.isArray(robots_txt) || typeof robots_txt != 'object') return result;

    if (robots_txt.status) {
      result.status_code = ''+robots_txt.status;
    }

} catch (e) {}
return result;
''';

select
    client,
    robots_txt_status_info.status_code as status_code,
    count(0) as total,
    safe_divide(count(0), sum(count(0)) over (partition by client)) as pct

from
    (
        select
            _table_suffix as client,
            getrobotsstatusinfo(
                json_extract_scalar(payload, '$._robots_txt')
            ) as robots_txt_status_info
        from `httparchive.pages.2021_07_01_*`
    )
group by client, status_code
order by total desc
