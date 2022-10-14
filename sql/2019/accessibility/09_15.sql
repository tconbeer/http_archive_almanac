# standardSQL
# 09_15: % pages using duplicate aria-keyshortcuts, accesskey attrs
CREATE TEMPORARY FUNCTION hasDuplicates(values ARRAY<STRING>)
RETURNS BOOLEAN LANGUAGE js AS '''
return values.length != new Set(values).size;
''';

select
    client,
    countif(hasduplicates(aria_keyshortcuts)) as freq_aria_keyshortcuts,
    countif(hasduplicates(accesskeys)) as freq_accesskey
from
    (
        select
            client,
            regexp_extract_all(
                lower(body), '<[^>]+aria-keyshortcuts=[\'"]?([^\\s\'"]+)'
            ) as aria_keyshortcuts,
            regexp_extract_all(
                lower(body), '<[^>]+accesskey=[\'"]?([^\\s\'"]+)'
            ) as accesskeys
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
group by client
