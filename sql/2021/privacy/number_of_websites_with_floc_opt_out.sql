# standardSQL
# Pages that opt out of FLoC
with
    response_headers as (
        select
            client,
            page,
            rank,
            lower(json_value(response_header, '$.name')) as header_name,
            lower(json_value(response_header, '$.value')) as header_value
        from
            `httparchive.almanac.requests`,
            unnest(json_query_array(response_headers)) response_header
        where date = '2021-07-01' and firsthtml = true
    ),

    meta_tags as (
        select
            client,
            url as page,
            lower(json_value(meta_node, '$.http-equiv')) as tag_name,
            lower(json_value(meta_node, '$.content')) as tag_value
        from
            (
                select
                    _table_suffix as client,
                    url,
                    json_value(payload, '$._almanac') as metrics
                from `httparchive.pages.2021_07_01_*`
            ),
            unnest(json_query_array(metrics, '$.meta-nodes.nodes')) meta_node
        where json_value(meta_node, '$.http-equiv') is not null
    ),

    totals as (
        select client, rank_grouping, count(distinct page) as total_websites
        from
            `httparchive.almanac.requests`,
            unnest( [1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where date = '2021-07-01' and firsthtml = true and rank <= rank_grouping
        group by client, rank_grouping
    )

select
    client,
    rank_grouping,
    count(distinct page) as number_of_websites,
    total_websites,
    count(distinct page) / total_websites as pct_websites
from response_headers
full outer join
    meta_tags
    using(client, page),
    unnest( [1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
join totals using(client, rank_grouping)
where
    (
        # value could contain other policies
        (header_name = 'permissions-policy' and header_value like 'interest-cohort=()')
        or (tag_name = 'permissions-policy' and tag_value like 'interest-cohort=()')
    )
    and rank <= rank_grouping
group by client, rank_grouping, total_websites
order by rank_grouping, client
