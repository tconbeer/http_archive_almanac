# standardSQL
# pages that animate variable font axes
create temporary function animatesvariablefonts(css string)
returns boolean
language js
options (library = "gs://httparchive/lib/css-utils.js")
as
    '''
try {
  var ast = JSON.parse(css);
  return countDeclarations(ast.stylesheet.rules, {properties: 'transition', values: /font-variation-settings/}) > 0;
} catch (e) {
  return false;
}
'''
;

select
    client,
    countif(animates_variable_fonts > 0) as animates_variable_fonts,
    count(distinct page) as total,
    countif(animates_variable_fonts > 0) / count(distinct page) as pct
from
    (
        select
            client, page, countif(animatesvariablefonts(css)) as animates_variable_fonts
        from `httparchive.almanac.parsed_css`
        group by client, page
    )
group by client
