# standardSQL
# returns the file types for preload tags without the required crossorigin attribute
# helper to convert the href into a type
CREATE TEMPORARY FUNCTION getType (href STRING) RETURNS STRING AS (
  IF(
    REGEXP_CONTAINS(href, r'fonts\.googleapis\.com'),
    'fonts.googleapis.com',
    TRIM(TRIM(REGEXP_EXTRACT(href, r'\.[0-9a-z]+(?:[\?#]|$)'), '?'), '#')
  )
);

select
    client,
    gettype(trim(href, "'")) as type,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            client,
            regexp_extract_all(
                consolelog,
                r'A preload for (.+?) is found, but is not used because the request credentials mode does not match'
            ) as value
        from
            (
                select
                    _table_suffix as client,
                    json_extract(payload, '$._consoleLog') as consolelog
                from `httparchive.pages.2021_07_01_*`
            )
    )
cross join unnest(value) as href
group by client, type
order by client, freq desc
