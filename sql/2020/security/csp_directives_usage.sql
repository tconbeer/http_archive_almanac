# standardSQL
# CSP on home pages: popularity of different directives
create temporary function getheader(headers string, headername string)
returns string
deterministic
language js
as '''
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
    directive,
    count(0) as total_csp_headers,
    countif(
        regexp_contains(
            concat(' ', csp_header, ' '), concat(r'(?i)\W', directive, r'\W')
        )
    ) as num_with_directive,
    countif(
        regexp_contains(
            concat(' ', csp_header, ' '), concat(r'(?i)\W', directive, r'\W')
        )
    ) / count(0) as pct_with_directive
from
    (
        select
            client,
            getheader(
                json_extract(payload, '$.response.headers'), 'Content-Security-Policy'
            ) as csp_header
        from `httparchive.almanac.requests`
        where date = '2020-08-01' and firsthtml
    ),
    unnest(
        [
            'child-src',
            'connect-src',
            'default-src',
            'font-src',
            'frame-src',
            'img-src',
            'manifest-src',
            'media-src',
            'object-src',
            'prefetch-src',
            'script-src',
            'script-src-elem',
            'script-src-attr',
            'style-src',
            'style-src-elem',
            'style-src-attr',
            'worker-src',
            'base-uri',
            'plugin-types',
            'sandbox',
            'form-action',
            'frame-ancestors',
            'navigate-to',
            'report-uri',
            'report-to',
            'block-all-mixed-content',
            'referrer',
            'require-sri-for',
            'require-trusted-types-for',
            'trusted-types',
            'upgrade-insecure-requests'
        ]
    ) as directive
where csp_header is not null
group by client, directive
order by client, pct_with_directive desc
