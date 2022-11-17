# standardSQL
create temporary function getlogicalproperties(css string)
returns array<struct<property string, freq int64>>
language js
options (library = "gs://httparchive/lib/css-utils.js")
as
    '''
try {
  function compute(ast) {
    let ret = {
      logical: {},
      physical: {}
    };


    walkDeclarations(ast, ({property, value}) => {
      let isLogical = property.match(/\\b(block|inline|start|end)\\b/);
      let obj = ret[isLogical? "logical" : "physical"];

      let size = property.match(/^(min-|max-)?((block|inline)-size|width|height)$/);

      if (size) {
        incrementByKey(obj, (size[1] || "") + "size");
        return;
      }

      let borderRadius = property.match(/^border-([a-z]-)?radius$/);

      if (borderRadius) {
        incrementByKey(obj, "border-radius");
      }

      let boxModel = property.match(/^(border|margin|padding)(?!-width|-style|-color|$)\\b/);

      if (boxModel) {
        incrementByKey(obj, boxModel[1]);
      }

      if (/^overflow-/.test(property)) {
        incrementByKey(obj, "overflow");
      }

      if (matches(property, [/^inset\\b/, "top", "right", "bottom", "left"])) {
        incrementByKey(ret[property.startsWith("inset")? "logical" : "physical"], "inset");
      }

      if (matches(property, ["clear", "float", "caption-side", "resize", "text-align"])) {
        isLogical = value.match(/\\b(block|inline|start|end)\\b/);
        let obj = ret[isLogical? "logical" : "physical"];
        incrementByKey(obj, property);
      }


    }, {
      properties: [
        "clear", "float", "caption-side", "resize", "text-align",
        /^overflow-/,
        "inset",
        /\\b(block|inline|start|end|top|right|bottom|left|width|height)\\b/,
      ]
    });

    ret.logical.total = sumObject(ret.logical);
    ret.physical.total = sumObject(ret.physical);

    ret.logical = sortObject(ret.logical);
    ret.physical = sortObject(ret.physical);


    return ret;
  }
  var ast = JSON.parse(css);
  var i18n = compute(ast);
  return Object.entries(i18n.logical).filter(([property]) => {
    return property != 'total';
  }).map(([property, freq]) => {
    return {property, freq};
  });
} catch (e) {
  return [];
}
'''
;

select *
from
    (
        select
            client,
            property,
            count(distinct page) as pages,
            sum(freq) as freq,
            sum(sum(freq)) over (partition by client) as total,
            sum(freq) / sum(sum(freq)) over (partition by client) as pct
        from
            (
                select client, page, prop.property, prop.freq
                from
                    `httparchive.almanac.parsed_css`,
                    unnest(getlogicalproperties(css)) as prop
                # Limit the size of the CSS to avoid OOM crashes.
                where date = '2020-08-01' and length(css) < 0.1 * 1024 * 1024
            )
        group by client, property
    )
where pct >= 0.01
order by pct desc
