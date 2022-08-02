# standardSQL
# 17_19: Percentage of HTTPS responses by protocol
select
    a.client,
    if(cdn = 'ORIGIN', 'ORIGIN', 'CDN') as cdn,
    firsthtml,
    countif(ifnull(a.protocol, b.protocol) = 'HTTP/0.9') as http09,
    countif(ifnull(a.protocol, b.protocol) = 'HTTP/1.0') as http10,
    countif(ifnull(a.protocol, b.protocol) = 'HTTP/1.1') as http11,
    countif(ifnull(a.protocol, b.protocol) = 'HTTP/2') as http2,
    countif(
        ifnull(a.protocol, b.protocol) = 'H3-29'
        or ifnull(a.protocol, b.protocol) = 'H3-Q050'
    ) as http3,
    countif(
        ifnull(a.protocol, b.protocol) not in (
            'HTTP/0.9', 'HTTP/1.0', 'HTTP/1.1', 'HTTP/2', 'H3-29', 'H3-Q050'
        )
    ) as http_other,
    countif(issecure or ifnull(a.protocol, b.protocol) = 'HTTP/2') as tls_total,
    countif(ifnull(a.protocol, b.protocol) = 'HTTP/0.9') / count(0) as http09_pct,
    countif(ifnull(a.protocol, b.protocol) = 'HTTP/1.0') / count(0) as http10_pct,
    countif(ifnull(a.protocol, b.protocol) = 'HTTP/1.1') / count(0) as http11_pct,
    countif(ifnull(a.protocol, b.protocol) = 'HTTP/2') / count(0) as http2_pct,
    countif(
        ifnull(a.protocol, b.protocol) = 'H3-29'
        or ifnull(a.protocol, b.protocol) = 'H3-Q050'
    )
    / count(0) as http3_pct,
    countif(
        ifnull(a.protocol, b.protocol) not in (
            'HTTP/0.9', 'HTTP/1.0', 'HTTP/1.1', 'HTTP/2', 'H3-29', 'H3-Q050'
        )
    )
    / count(0) as http_other_pct,
    countif(issecure or ifnull(a.protocol, b.protocol) = 'HTTP/2')
    / count(0) as tls_pct,
    count(0) as total
from
    (
        select
            client,
            page,
            url,
            firsthtml,
            # WPT is inconsistent with protocol population.
            upper(
                ifnull(
                    json_extract_scalar(payload, '$._protocol'),
                    ifnull(
                        nullif(
                            json_extract_scalar(payload, '$._tls_next_proto'), 'unknown'
                        ),
                        nullif(
                            concat(
                                'HTTP/',
                                json_extract_scalar(payload, '$.response.httpVersion')
                            ),
                            'HTTP/'
                        )
                    )
                )
            ) as protocol,
            json_extract_scalar(payload, '$._tls_version') as tlsversion,

            # WPT joins CDN detection but we bias to the DNS detection which is the
            # first entry
            ifnull(
                nullif(regexp_extract(_cdn_provider, r'^([^,]*).*'), ''), 'ORIGIN'
            ) as cdn,
            cast(json_extract(payload, '$.timings.ssl') as int64) as tlstime,

            # isSecure reports what the browser thought it was going to use, but it
            # can get upgraded with STS OR UpgradeInsecure: 1
            if(
                starts_with(url, 'https')
                or json_extract_scalar(payload, '$._tls_version') is not null
                or cast(json_extract(payload, '$._is_secure') as int64) = 1,
                true,
                false
            ) as issecure,
            cast(json_extract(payload, '$._socket') as int64) as socket
        from `httparchive.almanac.requests`
        # WPT changes the response fields based on a redirect (url becomes the
        # Location path instead of the original) causing insonsistencies in the
        # counts, so we ignore them
        where resp_location = '' or resp_location is null and date = '2021-07-01'
    ) a
left join
    (
        select
            client,
            page,
            cast(json_extract(payload, '$._socket') as int64) as socket,
            any_value(
                upper(
                    ifnull(
                        json_extract_scalar(payload, '$._protocol'),
                        ifnull(
                            nullif(
                                json_extract_scalar(payload, '$._tls_next_proto'),
                                'unknown'
                            ),
                            nullif(
                                concat(
                                    'HTTP/',
                                    json_extract_scalar(
                                        payload, '$.response.httpVersion'
                                    )
                                ),
                                'HTTP/'
                            )
                        )
                    )
                )
            ) as protocol,
            any_value(json_extract_scalar(payload, '$._tls_version')) as tlsversion
        from `httparchive.almanac.requests`
        where
            json_extract_scalar(payload, '$._tls_version') is not null
            and ifnull(
                json_extract_scalar(payload, '$._protocol'),
                ifnull(
                    nullif(
                        json_extract_scalar(payload, '$._tls_next_proto'), 'unknown'
                    ),
                    nullif(
                        concat(
                            'HTTP/',
                            json_extract_scalar(payload, '$.response.httpVersion')
                        ),
                        'HTTP/'
                    )
                )
            )
            is not null
            and json_extract(payload, '$._socket') is not null
            and date = '2021-07-01'
        group by client, page, socket
    ) b
    on (a.client = b.client and a.page = b.page and a.socket = b.socket)

group by client, cdn, firsthtml
order by client desc, total desc
