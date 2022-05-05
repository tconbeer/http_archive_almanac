# standardSQL
# Most popular `content` property values.
# Combines hex values together to reduce duplication (used by icon fonts).
create temp function getcontentstrings(css string) returns array
< string
> language js
as '''
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    if (!('declarations' in rule)) {
      return values;
    }
    return values.concat(rule.declarations.filter(d => d.property.toLowerCase() == 'content').map(d => d.value));
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, []);
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
            if(
                regexp_contains(content, r'[\'"]\\[ef][0-9a-f]{3}[\'"]'),
                '"\\f000"-like',
                if(
                    regexp_contains(content, r'[\'"]\\[a-f0-9]{4}[\'"]'),
                    '"\\hex{4}"-like',
                    content
                )
            ) as content,
            count(distinct page) as pages,
            total_pages,
            count(distinct page) / total_pages as pct_pages,
            count(0) as freq,
            sum(count(0)) over (partition by client) as total,
            count(0) / sum(count(0)) over (partition by client) as pct
        from
            (
                select client, count(distinct page) as total_pages
                from `httparchive.almanac.parsed_css`
                where date = '2021-07-01'
                group by client
            )
        join
            `httparchive.almanac.parsed_css`
            using
            (client),
            unnest(getcontentstrings(css)) as content
        where date = '2021-07-01'
        group by client, content, total_pages
    )
where pages >= 1000
order by pct_pages desc
limit 200
