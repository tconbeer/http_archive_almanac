# standardSQL
# returns the number of unused font files (assuming they are the same font based on
# the filename) that were preloaded
# Ex: The below HTML will return 1:
# 
# <link rel="preload" href="./roboto.woff2" as="font" />
# <link rel="preload" href="./roboto.woff" as="font" />
# <link rel="preload" href="./montserrat.woff2" as="font" />
CREATE TEMPORARY FUNCTION getUnusedFontDownloadsCount(almanac_string STRING)
RETURNS INT64 LANGUAGE js AS '''
try {
  const almanac = JSON.parse(almanac_string);
  if (Array.isArray(almanac) || typeof almanac != "object") return null;

  let nodes = almanac["link-nodes"]["nodes"];
  nodes = typeof nodes == "string" ? JSON.parse(nodes) : nodes;

  const preloadedFonts = nodes.filter(
    (n) => n["as"] === "font" && n["rel"] === "preload"
  );

  // extract the font file name and extension
  const fontFiles = preloadedFonts.map((r) => {
    const filePathParts = r.href.split("/");
    return filePathParts[filePathParts.length - 1];
  });

  if (fontFiles.length === 0) {
    return null;
  }

  // returns a key-value-pair with the filename and array of extensions used
  // Ex: { "roboto": [".woff2", ".woff"], "montserrat": [".woff2"] }
  const preloadedFontSet = fontFiles.reduce((acc, n) => {
    const regexp = new RegExp("\\.[0-9a-z]+$");
    const match = n.match(regexp);

    if (match) {
      const ext = match[0];
      const filename = n.replace(ext, "");

      return {
        ...acc,
        [filename]: [...(acc[filename] ? acc[filename] : []), ext],
      };
    }
  }, {});

  return Object.values(preloadedFontSet).reduce((acc, n) => {
    if (n.find((m) => m === ".woff2" || m === "woff2")) {
      return acc + n.length - 1;
    }

    return acc;
  }, 0);
} catch {
  return null;
}
''';

select
    client,
    unused_font_count,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            _table_suffix as client,
            getunusedfontdownloadscount(
                json_extract_scalar(payload, '$._almanac')
            ) as unused_font_count
        from `httparchive.pages.2021_07_01_*`
    )
where unused_font_count is not null
group by client, unused_font_count
order by client, unused_font_count
