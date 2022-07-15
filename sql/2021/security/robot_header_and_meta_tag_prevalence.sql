# standardSQL
# Prevalence of X-robots-tag header values and robots meta values.
with
    meta_tags as (
        select
            client,
            url as page,
            lower(json_value(meta_node, '$.content')) as robots_content
        from
            (
                select
                    _table_suffix as client,
                    url,
                    json_value(payload, '$._almanac') as metrics
                from `httparchive.pages.2021_07_01_*`
            ),
            unnest(json_query_array(metrics, '$.meta-nodes.nodes')) meta_node
        where lower(json_value(meta_node, '$.name')) = 'robots'
    ),

    robot_headers as (
        select
            client,
            url as page,
            lower(json_value(response_header, '$.value')) as robot_header_value
        from
            (
                select client, url, response_headers
                from `httparchive.almanac.requests`
                where firsthtml = true and date = '2021-07-01'
            ),
            unnest(json_query_array(response_headers)) as response_header
        where lower(json_value(response_header, '$.name')) = 'x-robots-tag'
    ),

    total_nb_pages as (
        select _table_suffix as client, count(distinct url) as total_nb_pages
        from `httparchive.pages.2021_07_01_*`
        group by client
    )

select
    client,
    total_nb_pages as total,
    countif(
        robots_content is not null or robot_header_value is not null
    ) as count_robots,
    countif(robots_content is not null or robot_header_value is not null)
    / min(total_nb_pages.total_nb_pages) as pct_robots,
    count(robots_content) as count_robots_content,
    count(robots_content) / total_nb_pages as pct_robots_content,
    count(robot_header_value) as count_robot_header_value,
    count(robot_header_value) / total_nb_pages as pct_robot_header_value,
    countif(
        regexp_contains(robots_content, r'.*noindex.*')
        or regexp_contains(robot_header_value, r'.*noindex.*')
    ) as count_noindex,
    countif(
        regexp_contains(robots_content, r'.*noindex.*')
        or regexp_contains(robot_header_value, r'.*noindex.*')
    ) / countif(robots_content is not null or robot_header_value is not null)
    as pct_noindex,
    countif(
        regexp_contains(robots_content, r'.*nofollow.*')
        or regexp_contains(robot_header_value, r'.*nofollow.*')
    ) as count_nofollow,
    countif(
        regexp_contains(robots_content, r'.*nofollow.*')
        or regexp_contains(robot_header_value, r'.*nofollow.*')
    ) / countif(robots_content is not null or robot_header_value is not null)
    as pct_nofollow,
    countif(
        regexp_contains(robots_content, r'.*nosnippet.*')
        or regexp_contains(robot_header_value, r'.*nosnippet.*')
    ) as count_nosnippet,
    countif(
        regexp_contains(robots_content, r'.*nosnippet.*')
        or regexp_contains(robot_header_value, r'.*nosnippet.*')
    ) / countif(robots_content is not null or robot_header_value is not null)
    as pct_nosnippet,
    countif(
        regexp_contains(robots_content, r'.*noarchive.*')
        or regexp_contains(robot_header_value, r'.*noarchive.*')
    ) as count_noarchive,
    countif(
        regexp_contains(robots_content, r'.*noarchive.*')
        or regexp_contains(robot_header_value, r'.*noarchive.*')
    ) / countif(robots_content is not null or robot_header_value is not null)
    as pct_noarchive
from meta_tags
full outer join robot_headers using(client, page)
join total_nb_pages using(client)
group by client, total_nb_pages
order by client
