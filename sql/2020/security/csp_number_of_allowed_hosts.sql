# standardSQL
# CSP on home pages: number of unique headers, header length and number of allowed
# hosts in all directives
CREATE TEMPORARY FUNCTION getHeader(headers STRING, headername STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js AS '''
  const parsed_headers = JSON.parse(headers);
  const matching_headers = parsed_headers.filter(h => h.name.toLowerCase() == headername.toLowerCase());
  if (matching_headers.length > 0) {
    return matching_headers[0].value;
  }
  return null;
''';
CREATE TEMP FUNCTION getNumUniqueHosts(str STRING) AS (
  (SELECT COUNT(DISTINCT x) FROM UNNEST(REGEXP_EXTRACT_ALL(str, r'(?i)(https*://[^\s;]+)[\s;]')) AS x)
);

select
    client,
    percentile,
    count(0) as total_requests,
    countif(csp_header is not null) as total_csp_headers,
    countif(csp_header is not null) / count(0) as pct_csp_headers,
    count(distinct csp_header) as num_unique_csp_headers,
    approx_quantiles(length(csp_header), 1000 ignore nulls)[
        offset(percentile * 10)
    ] as csp_header_length,
    approx_quantiles(getnumuniquehosts(csp_header), 1000 ignore nulls)[
        offset(percentile * 10)
    ] as unique_allowed_hosts
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
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by client, percentile
order by client, percentile
