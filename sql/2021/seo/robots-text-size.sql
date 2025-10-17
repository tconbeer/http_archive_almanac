# standardSQL
# Robots txt size by size bins (size in KiB)
# Note: Main story is robots.txt over 500 KiB which is Google's limit
# This is reason that size bins were used instead of quantiles
# helper to get robots size in kibibytes (KiB)
# Note: Assumes mostly ASCII 1byte = 1character.  Size is collected by
# custom measurement as string length.
create temporary function getrobotssize(payload string)
returns float64
language js
as '''
try {
  var $ = JSON.parse(payload);
  var robots = JSON.parse($._robots_txt);
  return robots['size']/1024;
} catch (e) {
  return 0;
}
'''
;

select
    client,
    count(distinct(site)) as sites,
    safe_divide(
        countif(robots_size > 0 and robots_size <= 100), count(distinct(site))
    ) as pct_0_100,
    safe_divide(
        countif(robots_size > 100 and robots_size <= 200), count(distinct(site))
    ) as pct_100_200,
    safe_divide(
        countif(robots_size > 200 and robots_size <= 300), count(distinct(site))
    ) as pct_200_300,
    safe_divide(
        countif(robots_size > 300 and robots_size <= 400), count(distinct(site))
    ) as pct_300_400,
    safe_divide(
        countif(robots_size > 400 and robots_size <= 500), count(distinct(site))
    ) as pct_400_500,
    safe_divide(countif(robots_size > 500), count(distinct(site))) as pct_gt500,
    safe_divide(countif(robots_size = 0), count(distinct(site))) as pct_missing,
    countif(robots_size > 500) as count_gt500,
    countif(robots_size = 0) as count_missing
from
    (
        select
            _table_suffix as client, url as site, getrobotssize(payload) as robots_size
        from `httparchive.pages.2021_07_01_*`
    )
group by client
order by client desc
