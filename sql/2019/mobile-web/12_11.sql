# standardSQL
# links or buttons only containing an icon
create temporary function hasbuttoniconset(payload string)
returns bool language js
as '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    if(almanac['12.11'] > 0) {
        return true;
    }
    return false;
  } catch (e) {
    return false;
  }
'''
;

select
    count(url) as total,
    round(countif(hasbuttoniconset(payload)) * 100 / count(0), 2) as pct_has_icon_button
from `httparchive.pages.2019_07_01_mobile`
