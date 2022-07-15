# standardSQL
# 04_20: % of pages having a captions track when necessary (see also 09_07)
# Caveat: This does not necessarily enforce that the track is within the media element.
create temporary function getmediaelements(payload string)
returns array
< string
> language js as '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count);
  if (Array.isArray(elements) || typeof elements != 'object') return [];
  var mediaElements = new Set(['audio', 'video', 'track']);
  return Object.keys(elements).filter(e => mediaElements.has(e));
} catch (e) {
  return [];
}
'''
;

select
    client,
    countif('track' in unnest(media_elements)) as freq,
    count(0) as total,
    round(countif('track' in unnest(media_elements)) * 100 / count(0), 2) as pct
from
    (
        select _table_suffix as client, getmediaelements(payload) as media_elements
        from `httparchive.pages.2019_07_01_*`
    )
where 'audio' in unnest(media_elements) or 'video' in unnest(media_elements)
group by client
