# standardSQL
# 09_14: % pages using aria-keyshortcuts, accesskey attrs
select
    client,
    countif(aria_keyshortcuts) as freq_aria_keyshortcuts,
    countif(accesskey) as freq_accesskey,
    total,
    round(countif(aria_keyshortcuts) * 100 / total, 2) as pct_aria_keyshortcuts,
    round(countif(accesskey) * 100 / total, 2) as pct_accesskey
from
    (
        select
            client,
            regexp_contains(body, '(?i)<[^>]+aria-keyshortcuts=') as aria_keyshortcuts,
            regexp_contains(body, '(?i)<[^>]+accesskey=') as accesskey
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.pages.2019_07_01_*`
        group by _table_suffix
    )
    using(client)
group by client, total
