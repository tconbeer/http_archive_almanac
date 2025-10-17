# standardSQL
# Float styles
create temporary function getlayoutusage(css string)
returns array<struct<name string, value int64>>
language js
options (library = "gs://httparchive/lib/css-utils.js")
as '''
try {
  const ast = JSON.parse(css);
  let ret = {};

  walkDeclarations(ast, ({property, value}) => {
    let key;

    if (property === "float") {
      key = "floats";
    }
    else if (/^table(-|$)/.test(value)) {
      key = "css-tables";
    }
    else {
      key = value.replace(/-(webkit|moz|o|webkit|khtml)-|!.+$/g, "").toLowerCase();
    }

    incrementByKey(ret, key);
  }, {
    properties: ["display", "position", "float"],
    not: {
      values: [
        "inherit", "initial", "unset", "revert",
        /\\bvar\\(--/,
        "static", "relative", "none"
      ]
    }
  });

  ret = sortObject(ret);

  return Object.entries(ret).map(([name, value]) => ({name, value}));
} catch (e) {
  return [];
}
'''
;

select *, pages / total_pages as pct_pages
from
    (
        select
            client,
            layout,
            sum(value) as freq,
            sum(sum(value)) over (partition by client) as total,
            sum(value) / sum(sum(value)) over (partition by client) as pct,
            count(distinct page) as pages
        from
            (
                select client, page, layout.name as layout, layout.value
                from
                    `httparchive.almanac.parsed_css`,
                    unnest(getlayoutusage(css)) as layout
                where date = '2021-07-01'
            )
        group by client, layout
    )
join
    (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.summary_pages.2021_07_01_*`
        group by client
    ) using (client)
where pages >= 100
order by pct desc
