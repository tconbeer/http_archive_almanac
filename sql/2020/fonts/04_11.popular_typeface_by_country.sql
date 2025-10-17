# standardSQL
# popular typeface by country
create temporary function getfontfamilies(css string)
returns
    array <
        string > language js
        as
            '''
try {
    var $ = JSON.parse(css);
    return $.stylesheet.rules.filter(rule => rule.type == 'font-face').map(rule => {
        var family = rule.declarations && rule.declarations.find(d => d.property == 'font-family');
        return family && family.value.replace(/[\'"]/g, '');
    }).filter(family => family);
} catch (e) {
    return [];
}
'''
;

select client, country, font_family, freq, total, pct
from
    (
        select
            client,
            country,
            font_family,
            count(0) as freq,
            sum(count(0)) over (partition by client) as total,
            count(0) / sum(count(0)) over (partition by client) as pct,
            row_number() over (
                partition by client, country order by count(0) desc
            ) as sort_row
        from
            `httparchive.almanac.parsed_css`,
            unnest(getfontfamilies(css)) as font_family
        join
            (
                select distinct
                    origin,
                    device,
                    `chrome-ux-report`.experimental.get_country(country_code) as country
                from `chrome-ux-report.materialized.country_summary`
                where yyyymm = 202008
            )
            on concat(origin, '/') = page
            and if(device = 'desktop', 'desktop', 'mobile') = client
        where date = '2020-08-01'
        group by client, country, font_family
        order by client, country, freq desc
    )
where sort_row <= 1
