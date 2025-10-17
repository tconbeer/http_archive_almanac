create temporary function getresourcehints(payload string)
returns
    array <struct <name string, href string >> language js as '''
var hints = new Set(['preload', 'prefetch', 'preconnect', 'prerender', 'dns-prefetch']);
try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    return almanac['link-nodes'].nodes.reduce((results, link) => {
        var hint = link.rel.toLowerCase();
        if (!hints.has(hint)) {
            return results;
        }
        results.push({
            name: hint,
            href: link.href
        });
        return results;
    }, []);
} catch (e) {
    return [];
}
'''
;
select
    client,
    name,
    count(distinct page) as pages,
    sum(count(distinct page)) over (partition by client) as total,
    count(distinct page)
    / sum(count(distinct page)) over (partition by client) as pct_hints,
    approx_quantiles(fcp, 1000)[offset(500)] as median_fcp,
    approx_quantiles(lcp, 1000)[offset(500)] as median_lcp
from
    (
        select distinct
            _table_suffix as client,
            url as page,
            hint.name,
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
        left join unnest(getresourcehints(payload)) as hint
    )
left join
    (
        select client, page, type
        from `httparchive.almanac.requests`
        where date = '2020-08-01'
    ) using (client, page)
where type = 'font'
group by client, name, type
order by pct_hints desc
