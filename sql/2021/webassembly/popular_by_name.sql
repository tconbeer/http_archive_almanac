select
    client,
    case
        when regexp_contains(url, r'/(hyphenopoly|patterns).*/[a-z-]{2,5}\.wasm')
        then '(hyphenopoly dictionary)'
        when ends_with(url, '.unityweb')
        then '(unityweb app)'
        else
            regexp_replace(
                -- lowercase & extract filename between last `/` and `.` or `?`
                -- trim trailing hashes to transform `name-0abc43234[...]` to `name`
                regexp_extract(lower(url), r'.*/([^./?]*)'), r'-[0-9a-f]{20,32}$', ''
            )
    end as name,
    count(0) as count,
    count(distinct filename) as count_versions,
    count(distinct net.reg_domain(url)) as count_serving_hosts,
    min(url) as url
from `httparchive.almanac.wasm_stats`
where date = '2021-09-01'
group by client, name
order by count desc
