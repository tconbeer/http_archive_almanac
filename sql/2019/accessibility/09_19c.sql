# standardSQL
# 09_19c: % valid ARIA attributes
# Valid attributes from
# https://github.com/dequelabs/axe-core/blob/master/lib/commons/aria/index.js
create temporary function isvalidattribute(attr string)
returns boolean
as
    (
        attr in (
            'aria-atomic',
            'aria-busy',
            'aria-controls',
            'aria-current',
            'aria-describedby',
            'aria-disabled',
            'aria-dropeffect',
            'aria-flowto',
            'aria-grabbed',
            'aria-haspopup',
            'aria-hidden',
            'aria-invalid',
            'aria-keyshortcuts',
            'aria-label',
            'aria-labelledby',
            'aria-live',
            'aria-owns',
            'aria-relevant',
            'aria-roledescription'
        )
    )
;

select
    client,
    countif(isvalidattribute(attr)) as freq,
    count(attr) as total,
    round(countif(isvalidattribute(attr)) * 100 / count(attr), 2) as pct
from
    `httparchive.almanac.summary_response_bodies`,
    unnest(
        regexp_extract_all(lower(body), '<[^>]+\\b(aria-\\w+)=[\'"]?[\\w-]+')
    ) as attr
where date = '2019-07-01' and firsthtml and attr is not null
group by client
order by freq / total desc
