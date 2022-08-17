# standardSQL
# Gather lighthouse unused css and js by CrUX rank
select
    client,
    rank_grouping,
    count(distinct page) as pages,
    sum(unused_javascript) / count(distinct page) as unused_javascript_kib_avg,
    sum(unused_css_rules) / count(distinct page) as unused_css_rules_kib_avg

from
    (
        select _table_suffix as client, url as page, rank
        from `httparchive.summary_pages.2021_07_01_*`
        where _table_suffix = 'mobile'
    )

left join
    (
        select
            _table_suffix as client,
            url as page,
            safe_divide(
                cast(
                    json_extract_scalar(
                        report, '$.audits.unused-javascript.details.overallSavingsBytes'
                    ) as int64
                ),
                1024
            ) as unused_javascript,
            safe_divide(
                cast(
                    json_extract_scalar(
                        report, '$.audits.unused-css-rules.details.overallSavingsBytes'
                    ) as int64
                ),
                1024
            ) as unused_css_rules
        from `httparchive.lighthouse.2021_07_01_*`
    ) using (client, page),
    unnest([1 e3, 1 e4, 1 e5, 1 e6, 1 e7]) as rank_grouping
where rank <= rank_grouping
group by client, rank_grouping
order by rank_grouping
