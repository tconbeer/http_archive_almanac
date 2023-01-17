# standardSQL
# font_unicode_range_with_fcp
create temporary function getfonts(css string)
returns array<string>
language js
as '''
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
            if (d.property.toLowerCase() == 'unicode-range') {
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
    case when unicode != ' ' then 'unicode_ranges' else 'none' end as use_unicode,
    count(distinct page) as pages,
    sum(count(distinct page)) over (partition by client) as total,
    count(distinct page)
    / sum(count(distinct page)) over (partition by client) as pct_range,
    approx_quantiles(fcp, 1000)[offset(500)] as median_fcp,
    approx_quantiles(lcp, 1000)[offset(500)] as median_lcp
from
    (
        select client, page, unicode
        from `httparchive.almanac.parsed_css`
        left join unnest(getfonts(css)) as unicode
        where date = '2020-08-01'
        group by client, page, unicode
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
        group by _table_suffix, page, payload
    ) using (client, page)
group by client, use_unicode
order by pages, client desc
