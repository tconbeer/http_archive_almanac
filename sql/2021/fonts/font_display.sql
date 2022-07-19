# standardSQL
# font_display
create temporary function getfontdisplay(css string)
returns array
< string
> language js as '''
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
            if (d.property.toLowerCase() == 'font-display') {
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
    font_display,
    count(distinct page) as pages,
    sum(count(distinct page)) over (partition by client) as total,
    count(distinct page)
    / sum(count(distinct page)) over (partition by client) as pct_display,
    approx_quantiles(fcp, 1000)[offset(500)] as median_fcp,
    approx_quantiles(lcp, 1000)[offset(500)] as median_lcp
from
    (
        select distinct client, page, font_display
        from `httparchive.almanac.parsed_css`
        left join unnest(getfontdisplay(css)) as font_display
        where date = '2021-07-01'
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
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix, url, payload
    )
    using
    (client, page)
group by client, font_display
order by pages desc
