create temp function parsecss(stylesheet string)
returns string
language js
options (library = "gs://httparchive/lib/parse-css.js")
as '''
  try {
    var css = parse(stylesheet)
    return JSON.stringify(css);
  } catch (e) {
    '';
  }
'''
;

select date, client, page, 'inline' as url, parsecss(style) as css
from
    (
        select date, client, page, url, body
        from `httparchive.almanac.summary_response_bodies`
        where date = '2020-08-01' and firsthtml
    ),
    unnest(regexp_extract_all(body, '(?i)<style[^>]*>(.*)</style>')) as style
# 3 MB
where style is not null and length(style) > 0 and length(style) < 3 * 1024 * 1024
