# standardSQL
# 08_35-37: Groupings of availably parsed values by percentage by client
# Mostly dynamic, but then removed all of the disinct values at "=" unless
# samesite rule is involved
select
    client,
    trim(
        substr(
            lower(policy),
            1,
            case
                when
                    (
                        strpos(lower(policy), 'samesite=strict') > 1 or strpos(
                            lower(policy), 'samesite=lax'
                        ) > 0 or strpos(lower(policy), 'samesite=none') > 1
                    )
                then length(policy)
                when strpos(policy, '=') > 1
                then strpos(lower(policy), '=') - 1
                else length(policy)
            end
        )
    ) as substr_policy,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from
    `httparchive.almanac.summary_response_bodies`,
    unnest(
        regexp_extract_all(lower(respotherheaders), r'set-cookie = ([^,\r\n]+)')
    ) as value,
    unnest(split(value, ';')) as policy
where date = '2019-07-01' and firsthtml
group by client, substr_policy
order by freq / total desc
