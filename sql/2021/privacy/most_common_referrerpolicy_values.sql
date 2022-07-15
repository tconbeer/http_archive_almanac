# standardSQL
# Most common values for Referrer-Policy (at site level)
with
    totals as (
        select _table_suffix as client, count(0) as total_websites
        from `httparchive.pages.2021_07_01_*`
        group by client
    ),

    referrer_policy_custom_metrics as (
        select
            _table_suffix as client,
            url,
            json_value(
                json_value(payload, '$._privacy'),
                '$.referrerPolicy.entire_document_policy'
            ) as entire_document_policy_meta
        from `httparchive.pages.2021_07_01_*`
    ),

    response_headers as (
        select
            client,
            page,
            lower(json_value(response_header, '$.name')) as name,
            lower(json_value(response_header, '$.value')) as value
        from
            `httparchive.almanac.requests`,
            unnest(json_query_array(response_headers)) response_header
        where date = '2021-07-01' and firsthtml = true
    ),

    referrer_policy_headers as (
        select client, page as url, value as entire_document_policy_header
        from response_headers
        where name = 'referrer-policy'
    )

select
    client,
    coalesce(
        entire_document_policy_header, entire_document_policy_meta
    ) as entire_document_policy,
    count(0) as number_of_websites_with_values,
    total_websites,
    count(0) / total_websites as pct_websites_with_values
from referrer_policy_custom_metrics
full outer join referrer_policy_headers using(client, url)
join totals using(client)
group by client, entire_document_policy, total_websites
order by client, number_of_websites_with_values desc
