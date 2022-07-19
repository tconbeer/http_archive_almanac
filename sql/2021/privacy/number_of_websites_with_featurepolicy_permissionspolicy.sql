# standardSQL
# Usage of Feature-Policy or Permissions-Policy
with
    page_ranks as (
        select client, page, rank
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and firsthtml = true
    ),

    response_headers as (
        select
            client,
            page,
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
    )

select
    *,
    number_of_websites_with_feature_policy
    / number_of_websites as pct_websites_with_feature_policy,
    number_of_websites_with_permissions_policy
    / number_of_websites as pct_websites_with_permissions_policy,
    number_of_websites_with_any_policy
    / number_of_websites as pct_websites_with_any_policy
from
    (
        select
            client,
            rank_grouping,
            count(
                distinct if(
                    header_name = 'feature-policy' or tag_name = 'feature-policy',
                    page,
                    null
                )
            ) as number_of_websites_with_feature_policy,
            count(
                distinct if(
                    header_name = 'permissions-policy'
                    or tag_name = 'permissions-policy',
                    page,
                    null
                )
            ) as number_of_websites_with_permissions_policy,
            count(
                distinct if(
                    header_name = 'feature-policy'
                    or tag_name = 'feature-policy'
                    or header_name = 'permissions-policy'
                    or tag_name = 'permissions-policy',
                    page,
                    null
                )
            ) as number_of_websites_with_any_policy,
            count(distinct page) as number_of_websites
        from response_headers
        full outer join meta_tags using(client, page)
        join
            page_ranks
            using(client, page),
            unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where rank <= rank_grouping
        group by client, rank_grouping
    )
order by rank_grouping, client
