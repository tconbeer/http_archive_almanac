# standardSQL
create temporary function getcustompropertyvaluetypes(payload string)
returns array<struct<type string, freq int64>>
language js
options (library = "gs://httparchive/lib/css-utils.js")
as
    '''
try {
  function compute(vars) {
    function walkElements(node, callback) {
      if (Array.isArray(node)) {
        for (let n of node) {
          walkElements(n, callback);
        }
      }
      else if (node) {
        callback(node);

        if (node.children) {
          walkElements(node.children, callback);
        }
      }
    }

    let ret = {
      values: {},
      types: {},
      properties: {}
    };

    const colorKeywords = [
      "aliceblue", "antiquewhite", "aqua", "aquamarine", "azure", "beige", "bisque", "black", "blanchedalmond", "blue", "blueviolet", "brown", "burlywood", "cadetblue", "chartreuse",
      "chocolate", "coral", "cornflowerblue", "cornsilk", "crimson", "cyan", "darkblue", "darkcyan", "darkgoldenrod", "darkgray", "darkgreen", "darkgrey", "darkkhaki", "darkmagenta",
      "darkolivegreen", "darkorange", "darkorchid", "darkred", "darksalmon", "darkseagreen", "darkslateblue", "darkslategray", "darkslategrey", "darkturquoise", "darkviolet",
      "deeppink", "deepskyblue", "dimgray", "dimgrey", "dodgerblue", "firebrick", "floralwhite", "forestgreen", "fuchsia", "gainsboro", "ghostwhite", "gold", "goldenrod", "gray",
      "green", "greenyellow", "grey", "honeydew", "hotpink", "indianred", "indigo", "ivory", "khaki", "lavender", "lavenderblush", "lawngreen", "lemonchiffon", "lightblue", "lightcoral",
      "lightcyan", "lightgoldenrodyellow", "lightgray", "lightgreen", "lightgrey", "lightpink", "lightsalmon", "lightseagreen", "lightskyblue", "lightslategray", "lightslategrey",
      "lightsteelblue", "lightyellow", "lime", "limegreen", "linen", "magenta", "maroon", "mediumaquamarine", "mediumblue", "mediumorchid", "mediumpurple", "mediumseagreen",
      "mediumslateblue", "mediumspringgreen", "mediumturquoise", "mediumvioletred", "midnightblue", "mintcream", "mistyrose", "moccasin", "navajowhite", "navy", "oldlace",
      "olive", "olivedrab", "orange", "orangered", "orchid", "palegoldenrod", "palegreen", "paleturquoise", "palevioletred", "papayawhip", "peachpuff", "peru", "pink", "plum",
      "powderblue", "purple", "rebeccapurple", "red", "rosybrown", "royalblue", "saddlebrown", "salmon", "sandybrown", "seagreen", "seashell", "sienna", "silver", "skyblue",
      "slateblue", "slategray", "slategrey", "snow", "springgreen", "steelblue", "tan", "teal", "thistle", "tomato", "turquoise", "violet", "wheat", "white", "whitesmoke",
      "yellow", "yellowgreen",
      "ActiveBorder", "ActiveCaption", "AppWorkspace", "Background", "ButtonFace", "ButtonHighlight", "ButtonShadow", "ButtonText", "CaptionText",
      "GrayText", "Highlight", "HighlightText", "InactiveBorder", "InactiveCaption", "InactiveCaptionText", "InfoBackground", "InfoText",
      "Menu", "MenuText", "Scrollbar", "ThreeDDarkShadow", "ThreeDFace", "ThreeDHighlight", "ThreeDLightShadow", "ThreeDShadow", "Window", "WindowFrame", "WindowText",
      "transparent", "currentColor"
    ];

    const colorKeywordRegex = RegExp(`^(?:${colorKeywords.join("|")})$`, "gi");

    walkElements(vars.computed, node => {
      if (node.declarations) {
        for (let property in node.declarations) {
          let value;
          let o = node.declarations[property];

          if (property.startsWith("--")) {
            // Custom property set to a value that doesn't depend on other variables
            value = o.computed || o.value;
            value = value.trim(); // whitespace is prserved in custom props
          }
          else {
            incrementByKey(ret.properties, property);

            if (o.references) {
              let varCall = extractFunctionCalls(o.value, {names: "var"});

              if (varCall.length === 1 && varCall[0].pos[1] === o.value.length) {
                // The entire value is one var() call
                value = o.computed || o.value;
              }
            }
          }

          if (value) {
            incrementByKey(ret.values, value);

            // What type of value is it?
            let type;

            let call = null;
            // NOTE(rviscomi): Excluding XL values to avoid UDF timeouts.
            if (value.length < 1000) {
              call = extractFunctionCalls(value).filter(c => c.pos[0] === 0 && c.pos[1] === value.length)[0];
            }

            if (call) {
              let name = call.name;

              if (/^(?:rgba?|hsla?|color|lab|lch|hwb)$/i.test(name)) {
                type = "color";
              }
              else if (/^(rotate|skew|translate|matrix)(X|Y|Z)?$/.test(name)) {
                type = "transform";
              }
              else if (/^(.+-gradient|url|cross-fade|image)$/.test(name)) {
                type = "image";
              }
              else {
                type = name;
              }
            }
            else if (/^-?\\d*\\.?\\d+$/.test(value)) {
              type = "number";
            }
            else if (/^-?\\d*\\.?\\d+[a-z%]{1,8}$/.test(value)) {
              type = "dimension";
            }
            else if (/^#[a-f\\d]{3,8}$/.test(value) || colorKeywordRegex.test(value)) {
              type = "color";
            }
            else if (/^--|^font(-family)$/.test(property) && /^(?:(["']).+?\\1|[\\w-]+)(?:,\\s*(?:(["']).+?\\2|[\\w-]+))*$/i.test(value)) {
              type = "font_stack";
            }
            else {
              type = "other";
            }

            if (type) {
              incrementByKey(ret.types, type);
            }
          }
        }
      }
    });

    for (let type in ret) {
      ret[type] = sortObject(ret[type]);
    }

    return ret;
  }

  var vars = JSON.parse(payload);
  return Object.entries(compute(vars).types).map(([type, freq]) => ({type, freq}));
} catch (e) {
  return [];
}
'''
;

select distinct
    client,
    type,
    count(distinct if(type is null, null, page)) over (
        partition by client, type
    ) as pages,
    count(distinct page) over (partition by client) as total_pages,
    count(distinct if(type is null, null, page)) over (partition by client, type)
    / count(distinct page) over (partition by client) as pct_pages,
    sum(freq) over (partition by client, type) as freq,
    sum(freq) over (partition by client) as total,
    sum(freq) over (partition by client, type)
    / sum(freq) over (partition by client) as pct
from
    (
        select _table_suffix as client, url as page, value.type, value.freq
        from `httparchive.pages.2020_08_01_*`
        left join
            unnest(
                getcustompropertyvaluetypes(
                    json_extract_scalar(payload, "$['_css-variables']")
                )
            ) as value
    )
order by pct desc
