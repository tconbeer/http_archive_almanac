# standardSQL
# Cookie attributes (HttpOnly, Secure, SameSite, __Secure- and __Host- prefixes) for
# cookies set on first-party and third-party requests
CREATE TEMPORARY FUNCTION getSetCookieHeaders(headers STRING)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js AS '''
  const parsed_headers = JSON.parse(headers);
  const cookies = parsed_headers.filter(h => h.name.match(/set-cookie/i));
  const cookieValues = cookies.map(h => h.value);
  return cookieValues;
''';

select
    client,
    party,
    count(0) as total_cookies,
    countif(regexp_contains(cookie_value, r'(?i);.*httponly')) as count_httponly,
    countif(regexp_contains(cookie_value, r'(?i);.*httponly'))
    / count(0) as pct_httponly,
    countif(regexp_contains(cookie_value, r'(?i);.*secure')) as count_secure,
    countif(regexp_contains(cookie_value, r'(?i);.*secure')) / count(0) as pct_secure,
    countif(regexp_contains(cookie_value, r'(?i);.*samesite\s*=')) as count_samesite,
    countif(regexp_contains(cookie_value, r'(?i);.*samesite\s*='))
    / count(0) as pct_samesite,
    countif(
        regexp_contains(cookie_value, r'(?i);.*samesite\s*=\s*lax')
    ) as count_samesite_lax,
    countif(regexp_contains(cookie_value, r'(?i);.*samesite\s*=\s*lax'))
    / count(0) as pct_samesite_lax,
    countif(
        regexp_contains(cookie_value, r'(?i);.*samesite\s*=\s*strict')
    ) as count_samesite_strict,
    countif(regexp_contains(cookie_value, r'(?i);.*samesite\s*=\s*strict'))
    / count(0) as pct_samesite_strict,
    countif(
        regexp_contains(cookie_value, r'(?i);.*samesite\s*=\s*none')
    ) as count_samesite_none,
    countif(regexp_contains(cookie_value, r'(?i);.*samesite\s*=\s*none'))
    / count(0) as pct_samesite_none,
    countif(regexp_contains(cookie_value, r'(?i)^\s*__Secure-')) as count_secure_prefix,
    countif(regexp_contains(cookie_value, r'(?i)^\s*__Secure-'))
    / count(0) as pct_secure_prefix,
    countif(regexp_contains(cookie_value, r'(?i)^\s*__Host-')) as count_host_prefix,
    countif(regexp_contains(cookie_value, r'(?i)^\s*__Host-'))
    / count(0) as pct_host_prefix
from
    (
        select
            client,
            getsetcookieheaders(
                json_extract(payload, '$.response.headers')
            ) as cookie_values,
            if(net.reg_domain(url) = net.reg_domain(page), 1, 3) as party
        from `httparchive.almanac.requests`
        where date = '2020-08-01'
    ),
    unnest(cookie_values) as cookie_value
group by client, party
order by client, party
