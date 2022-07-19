# standardSQL
# Top selectors used with box-sizing: border-box
create temp function
getborderboxselectors(css string)
returns array
< string
> language js as '''
try {
  var $ = JSON.parse(css);
  return $.stylesheet.rules.flatMap(rule => {
    if (!rule.selectors) {
      return [];
    }

    const boxSizingPattern = /^(-(o|moz|webkit|ms)-)?box-sizing$/;
    const borderBoxPattern = /border-box/;
    if (!rule.declarations.find(d => {
      return boxSizingPattern.test(d.property) && borderBoxPattern.test(d.value);
    })) {
      return [];
    }

    return rule.selectors;
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
            selector,
            count(distinct page) as pages,
            any_value(total_pages) as total_pages,
            count(distinct page) / any_value(total_pages) as pct_pages,
            count(0) as freq,
            sum(count(0)) over (partition by client) as total,
            count(0) / sum(count(0)) over (partition by client) as pct
        from
            (
                select client, page, selector
                from
                    `httparchive.almanac.parsed_css`,
                    unnest(getborderboxselectors(css)) as selector
                where date = '2021-07-01'
            )
        join
            (
                select _table_suffix as client, count(0) as total_pages
                from `httparchive.summary_pages.2021_07_01_*`
                group by client
            )
            using
            (client)
        group by client, selector
    )
order by pct desc
limit 1000
