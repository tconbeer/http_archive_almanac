create or replace table `httparchive.almanac.wasm_stats`  -- noqa: disable=L044
partition by date cluster by client as
select date('2021-09-01') as date, *
from
    (
        select * except (_table_suffix), _table_suffix as client
        from (select * except (size) from `blink-httparchive-research.rreverser2.wasms`)
        join `blink-httparchive-research.rreverser2.wasm_stats` using (filename)
        join `httparchive.summary_requests.2021_09_01_*` using (url)
        join
            (
                select url as page, pageid, _table_suffix
                from `httparchive.summary_pages.2021_09_01_*`
            ) using (_table_suffix, pageid)
    )
