# standardSQL
# Correlations between various JS factors on UX (mobile only)
select
    corr(performance_score, bytesjs) as js_bytes_on_performance_score,
    corr(accessibility_score, bytesjs) as js_bytes_on_accessibility_score,
    corr(tbt, bytesjs) as js_bytes_on_tbt,
    corr(
        performance_score, third_party_scripts
    ) as third_party_scripts_on_performance_score,
    corr(
        accessibility_score, third_party_scripts
    ) as third_party_scripts_on_accessibility_score,
    corr(tbt, third_party_scripts) as third_party_scripts_on_tbt,
    corr(
        performance_score, num_async_scripts
    ) as num_async_scripts_on_performance_score,
    corr(
        accessibility_score, num_async_scripts
    ) as num_async_scripts_on_accessibility_score,
    corr(tbt, num_async_scripts) as num_async_scripts_on_tbt
from
    (
        select pageid, url as page, bytesjs
        from `httparchive.summary_pages.2020_09_01_mobile`
    )
join
    (
        select
            url as page,
            safe_cast(
                json_extract_scalar(report, '$.categories.performance.score') as float64
            ) as performance_score,
            safe_cast(
                json_extract_scalar(
                    report, '$.categories.accessibility.score'
                ) as float64
            ) as accessibility_score,
            safe_cast(
                json_extract_scalar(
                    report, "$.audits['total-blocking-time'].numericValue"
                ) as float64
            ) as tbt
        from `httparchive.lighthouse.2020_09_01_mobile`
    ) using (page)
join
    (
        select pageid, sum(respsize) as third_party_scripts
        from `httparchive.summary_requests.2020_09_01_mobile`
        where
            type = 'script'
            and net.host(url) in (
                select domain
                from `httparchive.almanac.third_parties`
                where date = '2020-08-01' and category != 'hosting'
            )
        group by pageid
    ) using (pageid)
join
    (
        select
            url as page,
            safe_cast(
                json_extract_scalar(payload, '$._num_scripts_async') as int64
            ) as num_async_scripts
        from `httparchive.pages.2020_09_01_mobile`
    ) using (page)
