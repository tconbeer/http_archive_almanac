# standardSQL
# CSP: usage of default/script-src, and within the directive usage of strict-dynamic,
# nonce values, unsafe-inline and unsafe-eval
create temporary function getheader(headers string, headername string)
returns string deterministic
language js
as
    '''
  const parsed_headers = JSON.parse(headers);
  const matching_headers = parsed_headers.filter(h => h.name.toLowerCase() == headername.toLowerCase());
  if (matching_headers.length > 0) {
    return matching_headers[0].value;
  }
  return null;
'''
;
select
    client,
    total_pages,
    freq_csp,
    freq_default_script_src,
    safe_divide(freq_default_script_src, freq_csp) as pct_default_script_src_over_csp,
    freq_strict_dynamic,
    safe_divide(freq_strict_dynamic, freq_csp) as pct_strict_dynamic_over_csp,
    safe_divide(
        freq_strict_dynamic, freq_default_script_src
    ) as pct_strict_dynamic_over_csp_with_src,
    freq_nonce,
    safe_divide(freq_nonce, freq_csp) as pct_nonce_over_csp,
    safe_divide(freq_nonce, freq_default_script_src) as pct_nonce_over_csp_with_src,
    freq_unsafe_inline,
    safe_divide(freq_unsafe_inline, freq_csp) as pct_unsafe_inline_over_csp,
    safe_divide(
        freq_unsafe_inline, freq_default_script_src
    ) as pct_unsafe_inline_over_csp_with_src,
    freq_unsafe_eval,
    safe_divide(freq_unsafe_eval, freq_csp) as pct_unsafe_eval_over_csp,
    safe_divide(
        freq_unsafe_eval, freq_default_script_src
    ) as pct_unsafe_eval_over_csp_with_src
from
    (
        select
            client,
            count(0) as total_pages,
            countif(csp_header is not null) as freq_csp,
            countif(
                regexp_contains(csp_header, '(?i)(default|script)-src')
            ) as freq_default_script_src,
            countif(
                regexp_contains(
                    csp_header, '(?i)(default|script)-src[^;]+strict-dynamic'
                )
            ) as freq_strict_dynamic,
            countif(
                regexp_contains(csp_header, '(?i)(default|script)-src[^;]+nonce-')
            ) as freq_nonce,
            countif(
                regexp_contains(
                    csp_header, '(?i)(default|script)-src[^;]+unsafe-inline'
                )
            ) as freq_script_unsafe_inline,
            countif(
                regexp_contains(csp_header, '(?i)(default|script)-src[^;]+unsafe-eval')
            ) as freq_script_unsafe_eval,
            countif(
                regexp_contains(csp_header, '(?i)unsafe-inline')
            ) as freq_unsafe_inline,
            countif(regexp_contains(csp_header, '(?i)unsafe-eval')) as freq_unsafe_eval
        from
            (
                select
                    client,
                    getheader(
                        json_extract(payload, '$.response.headers'),
                        'Content-Security-Policy'
                    ) as csp_header
                from `httparchive.almanac.requests`
                where date = '2020-08-01' and firsthtml
            )
        group by client
    )
order by client
