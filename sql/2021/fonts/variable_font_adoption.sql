#standardSQL
#variable_font_with_fcp
CREATE TEMP FUNCTION getName(font_details STRING) RETURNS STRING LANGUAGE js AS '''
try {
  const metadata = RegExp('(not to be used for anything other than web font use!|web use only|web_use_only|:|;|^google$|copyright|©|(c)|rights reserved|published by|generated by|property of|trademark|version|v\\d+|release|untitled|^bold$|^light$|^semibold$|^defaults$|^normal$|^regular$|^[a-f0-9]+$|Vernon Adams|Jan Kovarik|Jan Kovarik|Mark Simonson|Paul D. Hunt|Kai Bernau|Kris Sowersby|Joshua Darden|Jos Buivenga|Yugo Kajiwara|Moslem Ebrahimi|Hadrien Boyer|Russell Benson|Ryan Martinson|Joen Asmussen|Olivier Gourvat|Hannes von Doehren|René Bieder|House Industries|GoDaddy|TypeSquare|Dalton Maag Ltd|_null_name_substitute_|^font$|Moveable Type)', 'i')
  return Object.values(JSON.parse(font_details).names).find(name => {
    name = name.trim();
    return name.length > 2 &&
      !metadata.test(name) &&
      isNaN(Number(name));
  });
} catch (e) {
  return null;
}
''';
SELECT
  client,
  name,
  COUNT(DISTINCT page) AS freq_vf,
  total_page,
  COUNT(DISTINCT page) / total_page AS pct_vf
FROM (
  SELECT
    client,
    page,
    getName(JSON_EXTRACT(payload, '$._font_details')) AS name
  FROM
    `httparchive.almanac.requests`
  WHERE
    date = '2021-07-01' AND
    type = 'font' AND
    REGEXP_CONTAINS(JSON_EXTRACT(payload, '$._font_details.table_sizes'), '(?i)gvar'))
JOIN (
  SELECT
    _TABLE_SUFFIX AS client,
    COUNT(0) AS total_page
  FROM
    `httparchive.pages.2021_07_01_*`
  GROUP BY
    _TABLE_SUFFIX)
USING
  (client, page)
WHERE
  name IS NOT NULL
GROUP BY
  client,
  name,
  total_page
HAVING
  freq_vf > 100
ORDER BY
  freq_vf DESC
