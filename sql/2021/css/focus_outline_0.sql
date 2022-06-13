# standardSQL
# Adoption of :focus pseudoclass and outline: 0 style
create temporary function getfocusstylesoutline0(
    css string
) returns array < bool > language js
options(
    library = "gs://httparchive/lib/css-utils.js"
) as '''
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    if (!('declarations' in rule)) {
      return values;
    }

    // Oversimplified but fast regex check.
    var focusRegEx = /:focus/;
    var fastFocusCheck = rule.selectors.find(selector => {
      return focusRegEx.test(selector);
    });
    if (!fastFocusCheck) {
      return values;
    }

    var hasFocusPseudoClass = rule.selectors.find(selector => {
      var tokens = parsel.tokenize(selector);
      return tokens.find(token => {
        return token.type == 'pseudo-class' && token.name == 'focus';
      });
    });

    if (!hasFocusPseudoClass) {
      return values;
    }

    var setsOutline0 = !!rule.declarations.find(d => d.property.toLowerCase() == 'outline' && d.value == '0');
    return values.concat(setsOutline0);
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, []);
} catch (e) {
  return [e];
}
'''
;

select
    client,
    countif(sets_focus_style) as pages_focus,
    countif(sets_focus_outline_0) as pages_focus_outline_0,
    any_value(total_pages) as total_pages,
    countif(sets_focus_style) / any_value(total_pages) as pct_pages_focus,
    countif(sets_focus_outline_0) / any_value(total_pages) as pct_pages_focus_outline_0
from
    (
        select
            client,
            page,
            count(0) > 0 as sets_focus_style,
            countif(sets_outline_0) > 0 as sets_focus_outline_0
        from
            `httparchive.almanac.parsed_css`,
            unnest(getfocusstylesoutline0(css)) as sets_outline_0
        where date = '2021-07-01'
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.summary_pages.2021_07_01_*`
        group by _table_suffix
    )
    using(client)
group by client
