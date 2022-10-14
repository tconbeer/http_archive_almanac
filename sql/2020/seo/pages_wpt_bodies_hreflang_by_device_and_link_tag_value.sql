# standardSQL
# page wpt_bodies metrics grouped by device and hreflang value in link tags
# helper to create percent fields
CREATE TEMP FUNCTION AS_PERCENT (freq FLOAT64, total FLOAT64) RETURNS FLOAT64 AS (
  ROUND(SAFE_DIVIDE(freq, total), 4)
);

# returns all the data we need from _wpt_bodies
CREATE TEMPORARY FUNCTION get_wpt_bodies_info(wpt_bodies_string STRING)
RETURNS STRUCT<
  hreflangs ARRAY<STRING>
> LANGUAGE js AS '''
var result = {
hreflangs: []
};

try {
    var wpt_bodies = JSON.parse(wpt_bodies_string);

    if (Array.isArray(wpt_bodies) || typeof wpt_bodies != 'object') return result;

    if (wpt_bodies.hreflangs && wpt_bodies.hreflangs.rendered && wpt_bodies.hreflangs.rendered.values) {
        result.hreflangs = wpt_bodies.hreflangs.rendered.values.map(v=> v); // seems to fix a coercion issue!
    }

} catch (e) {}
return result;
''';

select
    client,
    normalize_and_casefold(hreflang) as hreflang,
    total,
    count(0) as count,
    as_percent(count(0), total) as pct

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
                select _table_suffix, count(0) as total
                from `httparchive.pages.2020_08_01_*`
                # to get an accurate total of pages per device. also seems fast
                group by _table_suffix
            ) using (_table_suffix)
    ),
    unnest(wpt_bodies_info.hreflangs) as hreflang
group by total, hreflang, client
order by count desc, client desc
