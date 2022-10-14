# standardSQL
# page robots_txt metrics grouped by device and status code
# helper to create percent fields
CREATE TEMP FUNCTION AS_PERCENT (freq FLOAT64, total FLOAT64) RETURNS FLOAT64 AS (
  ROUND(SAFE_DIVIDE(freq, total), 4)
);

# returns all the data we need from _robots_txt
CREATE TEMPORARY FUNCTION get_robots_txt_info(robots_txt_string STRING)
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
