CREATE TEMP FUNCTION parseCSS(stylesheet STRING)
RETURNS STRING
LANGUAGE js
OPTIONS (library = "gs://httparchive/lib/parse-css.js")
AS '''
  try {
    var css = parse(stylesheet)
    return JSON.stringify(css);
  } catch (e) {
    '';
  }
''';

select date, client, page, url, parsecss(body) as css
from `httparchive.almanac.summary_response_bodies`
where date = '2020-08-01' and type = 'css' and length(body) < 3 * 1024 * 1024  # 3 MB
