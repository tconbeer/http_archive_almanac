# standardSQL
# Pages with unminified JS by 1P/3P
create temporary function getunminifiedjsurls(audit string)
returns
    array< struct<url string, wastedbytes int64 >> language js as '''
try {
  var $ = JSON.parse(audit);
  return $.details.items.map(({url, wastedBytes}) => {
    return {url, wastedBytes};
  });
} catch (e) {
  return [];
}
'''
;

select
    avg(pct_1p_wasted_bytes) as avg_pct_1p_wasted_bytes,
    avg(pct_3p_wasted_bytes) as avg_pct_3p_wasted_bytes
from
    (
        select
            page,
            sum(if(is_3p, 0, wasted_bytes)) / sum(wasted_bytes) as pct_1p_wasted_bytes,
            sum(if(is_3p, wasted_bytes, 0)) / sum(wasted_bytes) as pct_3p_wasted_bytes
        from
            (
                select
                    test.url as page,
                    net.host(unminified.url) is not null
                    and net.host(unminified.url) in (
                        select domain
                        from `httparchive.almanac.third_parties`
                        where date = '2021-07-01' and category != 'hosting'
                    ) as is_3p,
                    unminified.wastedbytes as wasted_bytes
                from
                    `httparchive.lighthouse.2021_07_01_mobile` as test,
                    unnest(
                        getunminifiedjsurls(
                            json_extract(report, "$.audits['unminified-javascript']")
                        )
                    ) as unminified
            )
        group by page
    )
