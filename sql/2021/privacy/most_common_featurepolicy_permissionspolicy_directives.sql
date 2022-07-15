# standardSQL
# Most common directives for Feature-Policy or Permissions-Policy
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
    ),

    totals as (
        select client, rank_grouping, count(distinct page) as total_websites
        from
            `httparchive.almanac.requests`,
            unnest( [1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where date = '2021-07-01' and firsthtml = true and rank <= rank_grouping
        group by client, rank_grouping
    ),

    merged_feature_policy as (
        select
            client,
            page,
            if(
                header_name = 'feature-policy', header_value, tag_value
            ) as feature_policy_value
        from response_headers
        full outer join meta_tags using(client, page)
        where header_name = 'feature-policy' or tag_name = 'feature-policy'
    ),

    merged_permissions_policy as (
        select
            client,
            page,
            if(
                header_name = 'permissions-policy', header_value, tag_value
            ) as permissions_policy_value
        from response_headers
        full outer join meta_tags using(client, page)
        where header_name = 'permissions-policy' or tag_name = 'permissions-policy'
    ),

    feature_policy_directives as (
        select
            client,
            page,
            array_agg(
                trim(split(trim(feature_policy_directive), ' ') [offset (0)])
            ) as directives
        from
            merged_feature_policy,
            unnest(split(feature_policy_value, ';')) feature_policy_directive
        group by client, page
    ),

    permissions_policy_directives as (
        select
            client,
            page,
            array_agg(
                trim(split(trim(permissions_policy_directive), '=') [offset (0)])
            ) as directives
        from
            merged_permissions_policy,
            unnest(split(permissions_policy_value, ',')) permissions_policy_directive
        group by client, page
    ),

    site_directives as (
        select
            client,
            page,
            -- distinct directives; https://stackoverflow.com/a/58194837/7391782
            array(
                select distinct d
                from
                    unnest(
                        array_concat(
                            feature_policy_directives.directives,
                            permissions_policy_directives.directives
                        )
                    ) d
                where trim(d) != ''
                order by d
            ) as directives
        from feature_policy_directives
        full outer join permissions_policy_directives using(client, page)
    )

select
    client,
    rank_grouping,
    directive,
    count(distinct page) as number_of_websites_with_directive,
    total_websites,
    count(distinct page) / total_websites as pct_websites_with_directive
from site_directives, unnest( [1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
join page_ranks using(client, page)
join totals using(client, rank_grouping), unnest(site_directives.directives) directive
where rank <= rank_grouping
group by client, rank_grouping, directive, total_websites
order by rank_grouping, client, number_of_websites_with_directive desc, directive
