# standardSQL
# Prevalence of landing pages over HTTPS that include at least one reference over
# HTTP, and distribution over ranking
select
    client,
    rank_grouping,
    count(
        distinct(case when regexp_contains(page, r'https://.*') then page end)
    ) as total_pages_over_https,
    count(
        distinct(
            case
                when
                    regexp_contains(page, r'https://.*')
                    and regexp_contains(url, r'http://.*')
                then page
            end
        )
    ) as count_pages_over_https_with_http_reference,
    count(
        distinct(
            case
                when
                    regexp_contains(page, r'https://.*')
                    and regexp_contains(url, r'http://.*')
                then page
            end
        )
    ) / count(distinct(case when regexp_contains(page, r'https://.*') then page end)
    ) as pct_pages_over_https_with_http_reference
from
    `httparchive.almanac.requests`,
    unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
where date = '2021-07-01' and rank <= rank_grouping
group by client, rank_grouping
order by client, rank_grouping
