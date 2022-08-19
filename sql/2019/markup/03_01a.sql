# standardSQL
# 03_01a: % of pages with deprecated elements
create temporary function containsdeprecatedelement(payload string)
returns boolean language js
as '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count)
  var deprecatedElements = new Set(["applet", "acronym", "bgsound", "dir", "frame", "frameset", "noframes", "isindex", "keygen", "listing", "menuitem", "nextid", "noembed", "plaintext", "rb", "rtc", "strike", "xmp", "basefont", "big", "blink", "center", "font", "marquee", "multicol", "nobr", "spacer", "tt"]);
  return !!Object.keys(elements).find(e => {
    return deprecatedElements.has(e);
  });
} catch (e) {
  return false;
}
'''
;

select
    _table_suffix as client,
    countif(containsdeprecatedelement(payload)) as pages,
    round(countif(containsdeprecatedelement(payload)) * 100 / count(0), 2) as pct_pages
from `httparchive.pages.2019_07_01_*`
group by client
