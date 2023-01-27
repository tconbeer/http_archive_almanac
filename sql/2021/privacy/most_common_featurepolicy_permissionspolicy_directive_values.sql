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
            unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
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
        full outer join meta_tags using (client, page)
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
        full outer join meta_tags using (client, page)
        where header_name = 'permissions-policy' or tag_name = 'permissions-policy'
    ),

    normalized_feature_policy as (  -- normalize
        select client, page, replace(feature_policy_value, "'", '') as policy_value  -- remove quotes
        from merged_feature_policy
    ),

    normalized_permissions_policy as (  -- normalize
        select
            client,
            page,
            replace(
                replace(
                    replace(
                        replace(
                            replace(
                                replace(
                                    replace(permissions_policy_value, ',', ';'),  -- swap directive delimiter
                                    '=',
                                    ' '
                                ),  -- drop name/value delimiter
                                '()',
                                'none'  -- special case for feature disabling
                            ),
                            '(',
                            ''
                        ),
                        ')',
                        ''
                    ),  -- remove parentheses
                    '"',
                    ''
                ),
                "'",
                ''
            )  -- remove quotes
            as policy_value
        from merged_permissions_policy
    )

select
    client,
    rank_grouping,
    rtrim(split(trim(directive), ' ')[offset(0)], ':') as directive_name,
    trim(origin) as origin,
    count(distinct page) as number_of_websites_with_directive,
    total_websites,
    count(distinct page) / total_websites as pct_websites_with_directive
from
    (
        select distinct *
        from
            (
                select *
                from normalized_feature_policy
                union all
                select *
                from normalized_permissions_policy
            )
    ),
    unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
join page_ranks using (client, page)
join
    totals using (client, rank_grouping),
    unnest(split(policy_value, ';')) directive,
    unnest(  -- Directive may specify explicit origins or not.
        if(
            array_length(split(trim(directive), ' ')) = 1,  -- test if any explicit origin is provided
            [trim(directive), ''],  -- if not, add a dummy empty origin to make the query work
            split(
                trim(directive), ' '  -- if it is, split the different origins
            )
        )
    ) as origin
with
offset as
offset
where trim(directive) != '' and
offset > 0 and rank <= rank_grouping
group by client, rank_grouping, directive_name, origin, total_websites
order by
    pct_websites_with_directive desc,
    rank_grouping,
    client,
    number_of_websites_with_directive desc,
    directive_name,
    origin
