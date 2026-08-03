# standardSQL
# font_subset_with_fcp
create temporary function getfont(css string)
returns array<string>
language js
as
    '''
try {
    var reduceValues = (values, rule) => {
        if ('rules' in rule) {
            return rule.rules.reduce(reduceValues, values);
        }
        if (!('declarations' in rule)) {
            return values;
        }
        if (rule.type != 'font-face') {
            return values;
        }
        rule.declarations.forEach(d => {
            if (d.property.toLowerCase() == 'subset' || d.property.toLowerCase() == 'text'  ) {
                values.push(d.value);
            }
        });
        return values;
    };
    var $ = JSON.parse(css);
    return $.stylesheet.rules.reduce(reduceValues, []);
} catch (e) {
    return [null];
}
'''
;
select
    client,
    font_subset,
    count(distinct page) as pages,
    sum(count(distinct page)) over (partition by client) as total,
    count(distinct page)
    / sum(count(distinct page)) over (partition by client) as pct_subset,
    approx_quantiles(fcp, 1000)[offset(500)] as median_fcp,
    approx_quantiles(lcp, 1000)[offset(500)] as median_lcp
from
    (
        select *
        from `httparchive.almanac.parsed_css`
        left join unnest(getfont(css)) as font_subset
        where date = '2020-08-01'
    )
join
    (
        select
            _table_suffix as client,
            url as page,
            cast(
                json_extract_scalar(
                    payload, "$['_chromeUserTiming.firstContentfulPaint']"
                ) as int64
            ) as fcp,
            cast(
                json_extract_scalar(
                    payload, "$['_chromeUserTiming.LargestContentfulPaint']"
                ) as int64
            ) as lcp
        from `httparchive.pages.2020_08_01_*`
        group by _table_suffix, url, payload
    ) using (client, page)
group by client, font_subset
order by pages, client desc
