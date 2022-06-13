# standardSQL
# 03_01b: Top deprecated elements
create temporary function getelements(payload string)
returns array
< string
> language js
as '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count);
  if (Array.isArray(elements) || typeof elements != 'object') return [];
  return Object.keys(elements);
} catch (e) {
  return [];
}
'''
;

create temporary function isdeprecated(element string) as (
    element in (
        'applet',
        'acronym',
        'bgsound',
        'dir',
        'frame',
        'frameset',
        'noframes',
        'isindex',
        'keygen',
        'listing',
        'menuitem',
        'nextid',
        'noembed',
        'plaintext',
        'rb',
        'rtc',
        'strike',
        'xmp',
        'basefont',
        'big',
        'blink',
        'center',
        'font',
        'marquee',
        'multicol',
        'nobr',
        'spacer',
        'tt'
    )
)
;

select
    _table_suffix as client,
    element as deprecated,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by _table_suffix), 2) as pct
from `httparchive.pages.2019_07_01_*`, unnest(getelements(payload)) as element
where isdeprecated(element)
group by client, deprecated
order by freq / total desc, client
