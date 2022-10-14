# standardSQL
# 03_05: % of pages with shadow roots
CREATE TEMPORARY FUNCTION hasShadowRoot(payload STRING) AS (
  JSON_EXTRACT_SCALAR(payload, '$._has_shadow_root') = 'true'
);

select
    _table_suffix as client,
    countif(hasshadowroot(payload)) as pages,
    round(countif(hasshadowroot(payload)) * 100 / count(0), 2) as pct_pages
from `httparchive.pages.2019_07_01_*`
group by client
