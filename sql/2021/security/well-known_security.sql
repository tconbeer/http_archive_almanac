# standardSQL
# Prevalence of (signed) /.well-known/security.txt endpoints and prevalence of
# included attributes (canonical, encryption, expires, policy).
select
    client,
    count(distinct page) as total_pages,
    countif(has_security_txt = 'true') as count_security_txt,
    countif(has_security_txt = 'true') / count(distinct page) as pct_security_txt,
    countif(signed = 'true') as count_signed,
    countif(signed = 'true') / countif(has_security_txt = 'true') as pct_signed,
    countif(canonical is not null) as canonical,
    countif(canonical is not null)
    / countif(has_security_txt = 'true') as pct_canonical,
    countif(encryption is not null) as encryption,
    countif(encryption is not null)
    / countif(has_security_txt = 'true') as pct_encryption,
    countif(expires is not null) as expires,
    countif(expires is not null) / countif(has_security_txt = 'true') as pct_expires,
    countif(policy is not null) as policy,
    countif(policy is not null) / countif(has_security_txt = 'true') as pct_policy
from
    (
        select
            _table_suffix as client,
            url as page,
            json_value(
                json_value(payload, '$._well-known'),
                '$."/.well-known/security.txt".found'
            ) as has_security_txt,
            json_query(
                json_value(payload, '$._well-known'),
                '$."/.well-known/security.txt".data.signed'
            ) as signed,
            json_query(
                json_value(payload, '$._well-known'),
                '$."/.well-known/security.txt".data.canonical'
            ) as canonical,
            json_query(
                json_value(payload, '$._well-known'),
                '$."/.well-known/security.txt".data.encryption'
            ) as encryption,
            json_query(
                json_value(payload, '$._well-known'),
                '$."/.well-known/security.txt".data.expires'
            ) as expires,
            json_query(
                json_value(payload, '$._well-known'),
                '$."/.well-known/security.txt".data.policy'
            ) as policy
        from `httparchive.pages.2021_07_01_*`
    )
group by client
