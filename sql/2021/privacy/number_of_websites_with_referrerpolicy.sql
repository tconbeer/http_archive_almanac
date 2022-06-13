# standardSQL
# Websites using Referrer-Policy
with
    referrer_policy_custom_metrics as (
        select
            _table_suffix as client,
            url as page,
            json_value(
                json_value(payload, '$._privacy'),
                '$.referrerPolicy.entire_document_policy'
            ) as entire_document_policy_meta,
            json_query_array(
                json_value(payload, '$._privacy'),
                '$.referrerPolicy.individual_requests'
            ) as individual_requests,
            json_query_array(
                json_value(payload, '$._privacy'), '$.referrerPolicy.link_relations'
            ) as link_relations
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
        select client, page, value as entire_document_policy_header
        from response_headers
        where name = 'referrer-policy'
    )

select
    *,
    number_of_websites_with_entire_document_policy_meta
    / number_of_websites
    as pct_websites_with_entire_document_policy_meta,
    number_of_websites_with_entire_document_policy_header
    / number_of_websites
    as pct_websites_with_entire_document_policy_header,
    number_of_websites_with_entire_document_policy
    / number_of_websites
    as pct_websites_with_entire_document_policy,
    number_of_websites_with_any_individual_requests
    / number_of_websites
    as pct_websites_with_any_individual_requests,
    number_of_websites_with_any_link_relations
    / number_of_websites
    as pct_websites_with_any_link_relations,
    number_of_websites_with_any_referrer_policy
    / number_of_websites
    as pct_websites_with_any_referrer_policy
from
    (
        select
            client,
            count(
                distinct if(entire_document_policy_meta is not null, page, null)
            ) as number_of_websites_with_entire_document_policy_meta,
            count(
                distinct if(entire_document_policy_header is not null, page, null)
            ) as number_of_websites_with_entire_document_policy_header,
            count(
                distinct if(
                    entire_document_policy_meta is not null
                    or entire_document_policy_header is not null,
                    page,
                    null
                )
            ) as number_of_websites_with_entire_document_policy,
            count(
                distinct if(array_length(individual_requests) > 0, page, null)
            ) as number_of_websites_with_any_individual_requests,
            count(
                distinct if(array_length(link_relations) > 0, page, null)
            ) as number_of_websites_with_any_link_relations,
            count(
                distinct if(
                    entire_document_policy_meta is not null
                    or entire_document_policy_header is not null
                    or array_length(individual_requests) > 0 or array_length(
                        link_relations
                    ) > 0,
                    page,
                    null
                )
            ) as number_of_websites_with_any_referrer_policy,
            count(distinct page) as number_of_websites
        from referrer_policy_custom_metrics
        full outer join referrer_policy_headers using(client, page)
        group by client
    )
order by client
