# standardSQL
# Distribution of the different version of the top 20 technologies used on the web.
select category, app, info, month, client, freq, pct
from
    (
        select
            info,
            tech.category_lower as category,
            top.app_lower as app,
            month,
            client,
            count(0) as freq,
            count(0) / sum(count(0)) over (
                partition by client, month, tech.category_lower, tech.app_lower
            ) as pct
        from
            (
                select
                    info,
                    trim(lower(category)) as category_lower,
                    trim(lower(app)) as app_lower,
                    left(_table_suffix, 10) as month,
                    if(
                        ends_with(_table_suffix, '_desktop'), 'desktop', 'mobile'
                    ) as client
                from `httparchive.technologies.*`
                where regexp_contains(info, r'\d+\.\d+') and _table_suffix >= '2020'
            ) as tech
        inner join
            (
                select
                    trim(lower(category)) as category_lower,
                    trim(lower(app)) as app_lower,
                    count(0) as num
                from `httparchive.technologies.*`
                where _table_suffix >= '2020'
                group by category_lower, app_lower
                order by num desc
                limit 20
            ) as top
            on (
                tech.category_lower = top.category_lower
                and tech.app_lower = top.app_lower
            )
        group by tech.category_lower, tech.app_lower, month, info, client
    )
where pct > 0.01
order by client, category, app, month, pct desc
