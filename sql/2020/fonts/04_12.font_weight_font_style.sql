# standardSQL
# font_weight_font_style
create temporary function getfonts(css string)
returns array<struct<weight string, stretch string, style string>>
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
        var props = {};
        rule.declarations.forEach(d => {
            if (d.property.toLowerCase() == 'font-weight') {
                props.weight = d.value;
            } else if (d.property.toLowerCase() == 'font-stretch') {
                props.stretch = d.value;
            } else if (d.property.toLowerCase() == 'font-style') {
                props.style = d.value;
            }
        });
        {
            values.push(props);
        }
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
    style,
    weight,
    stretch,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select distinct
            client,
            page,
            font.style as style,
            font.weight as weight,
            font.stretch as stretch
        from `httparchive.almanac.parsed_css`
        left join unnest(getfonts(css)) as font
        where date = '2020-08-01'
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
    ) using (client)
group by client, style, weight, stretch
order by pct desc
