# standardSQL
# Percent of requests with and without minification
CREATE TEMPORARY FUNCTION getUnminifiedJsBytes(audit STRING)
RETURNS ARRAY<INT64> LANGUAGE js AS '''
try {
  var $ = JSON.parse(audit);
  return $.details.items.map(({wastedBytes}) => wastedBytes);
} catch (e) {
  return [];
}
''';

select
    if(
        unminified_js_kbytes <= 200, ceil(unminified_js_kbytes / 10) * 10, 200
    ) as unminified_js_kbytes,
    count(0) as pages,
    sum(count(0)) over () as total,
    count(0) / sum(count(0)) over () as pct
from
    (
        select
            test.url as page,
            sum(ifnull(unminified_js_bytes, 0)) / 1024 as unminified_js_kbytes
        from `httparchive.lighthouse.2020_08_01_mobile` as test
        left join
            unnest(
                getunminifiedjsbytes(
                    json_extract(report, "$.audits['unminified-javascript']")
                )
            ) as unminified_js_bytes
        group by page
    )
group by unminified_js_kbytes
order by unminified_js_kbytes
