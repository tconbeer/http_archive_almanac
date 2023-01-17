# standardSQL
# icon_fonts
create temporary function checkssupports(css string)
returns array<string>
language js
as '''
try {
    var reduceValues = (values, rule) => {
        if (rule.type == 'stylesheet' && rule.supports.toLowerCase().includes('icon')) {
            values.push(rule.supports.toLowerCase());
        }
        return values;
    };
    var $ = JSON.parse(css);
    return $.stylesheet.rules.reduce(reduceValues, []);
} catch (e) {
    return [];
}
'''
;

select
    client,
    count(distinct page) as pages,
    total_page,
    count(distinct page) / total_page as pct_ficon
from `httparchive.almanac.parsed_css`
join
    (
        select _table_suffix as client, count(0) as total_page
        from `httparchive.summary_pages.2020_08_01_*`
        group by _table_suffix
    ) using (client)
where
    array_length(checkssupports(css)) > 0
    and date = '2020-08-01'
    or url like '%fontawesome%'
    or url like '%icomoon%'
    or url like '%fontello%'
    or url like '%iconic%'
group by client, url, total_page
order by client, pages desc
