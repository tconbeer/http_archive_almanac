# standardSQL
# 02_11: Top reset utils
select
    client,
    case
        lower(util)
        when 'normalize.css'
        then 'Normalize.css'
        when 'pure-css'
        then 'Pure CSS'
        when 'http://meyerweb.com/eric/tools/css/reset/'
        then 'Reset CSS'
        else util
    end as util,
    count(distinct page) as freq,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from
    (
        select client, page, body
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and type = 'css'
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by client
    ) using (client),
    # Search for reset util fingerprints in stylesheet comments.
    unnest(
        regexp_extract_all(
            body,
            '(?i)(normalize\\.css|pure\\-css|http://meyerweb\\.com/eric/tools/css/reset/)'
        )
    ) as util
group by client, total, util
order by freq / total desc
