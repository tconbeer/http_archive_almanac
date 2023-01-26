select
    client,
    policy,
    count(distinct page) as total_pages,
    count(
        distinct(
            case
                when
                    lower(json_value(meta_node, '$.http-equiv')) = lower(policy)
                    or lower(json_value(meta_node, '$.name')) = lower(policy)
                then page
            end
        )
    ) as count_policy,
    count(
        distinct(
            case
                when
                    lower(json_value(meta_node, '$.http-equiv')) = lower(policy)
                    or lower(json_value(meta_node, '$.name')) = lower(policy)
                then page
            end
        )
    )
    / count(distinct page) as pct_policy,
    policy in ('Content-Security-Policy', 'referrer') as is_allowed_as_meta
from
    (
        select
            _table_suffix as client,
            url as page,
            json_value(payload, '$._almanac') as metrics
        from `httparchive.pages.2021_07_01_*`
    ),
    unnest(json_query_array(metrics, '$.meta-nodes.nodes')) meta_node,
    unnest(
        [
            'Content-Security-Policy',
            'Content-Security-Policy-Report-Only',
            'Cross-Origin-Embedder-Policy',
            'Cross-Origin-Opener-Policy',
            'Cross-Origin-Resource-Policy',
            'Expect-CT',
            'Feature-Policy',
            'Permissions-Policy',
            'Referrer-Policy',
            'referrer',
            'Report-To',
            'Strict-Transport-Security',
            'X-Content-Type-Options',
            'X-Frame-Options',
            'X-XSS-Protection'
        ]
    ) as policy
group by client, policy
order by client, policy, count_policy desc
