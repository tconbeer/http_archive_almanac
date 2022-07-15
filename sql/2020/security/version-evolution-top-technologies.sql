# standardSQL
# Distribution of the different version of the top 20 technologies used on the web.
select category, app, info, month, client, freq, pct
from
    (
        select
            info,
            category_lower as category,
            app_lower as app,
            month,
            client,
            count(0) as freq,
            count(0) / sum(
                count(0)
            ) over (
                partition by client, month, category_lower, app_lower
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
                where
                    regexp_contains(info, r'\d+\.\d+')
                    and regexp_contains(_table_suffix, r'^20(20|19).*')
            )
        inner join
            (
                select
                    trim(lower(category)) as category_lower,
                    trim(lower(app)) as app_lower,
                    count(0) as num
                from `httparchive.technologies.*`
                where regexp_contains(_table_suffix, r'^20(20|19).*')
                group by category_lower, app_lower
                order by num desc
                limit 20
            )
            using(category_lower, app_lower)
        group by category_lower, app_lower, month, info, client
    )
where pct > 0.01
order by client, category, app, month, pct desc
