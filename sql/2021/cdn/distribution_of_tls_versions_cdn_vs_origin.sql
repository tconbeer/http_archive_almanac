# standardSQL
# distribution_of_tls_versions_cdn_vs_origin: Percentage of HTTPS responses by TLS
# Version with and without CDN
select
    a.client,
    if(cdn = 'ORIGIN', 'ORIGIN', 'CDN') as cdn,
    firsthtml,
    countif(ifnull(a.tlsversion, b.tlsversion) = 'TLS 1.0') as tls10,
    countif(ifnull(a.tlsversion, b.tlsversion) = 'TLS 1.1') as tls11,
    countif(ifnull(a.tlsversion, b.tlsversion) = 'TLS 1.2') as tls12,
    countif(ifnull(a.tlsversion, b.tlsversion) = 'TLS 1.3') as tls13,
    countif(ifnull(a.tlsversion, b.tlsversion) = 'TLS 1.0') / count(0) as tls10_pct,
    countif(ifnull(a.tlsversion, b.tlsversion) = 'TLS 1.1') / count(0) as tls11_pct,
    countif(ifnull(a.tlsversion, b.tlsversion) = 'TLS 1.2') / count(0) as tls12_pct,
    countif(ifnull(a.tlsversion, b.tlsversion) = 'TLS 1.3') / count(0) as tls13_pct,
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
                                'TLS ',
                                json_extract_scalar(payload, '$.response.httpVersion')
                            ),
                            'TLS '
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
                starts_with(url, 'https') or json_extract_scalar(
                    payload, '$._tls_version'
                ) is not null or cast(
                    json_extract(payload, '$._is_secure') as int64
                ) = 1,
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
                                    'TLS ',
                                    json_extract_scalar(
                                        payload, '$.response.httpVersion'
                                    )
                                ),
                                'TLS '
                            )
                        )
                    )
                )
            ) as protocol,
            any_value(json_extract_scalar(payload, '$._tls_version')) as tlsversion
        from `httparchive.almanac.requests`
        where
            json_extract_scalar(payload, '$._tls_version') is not null and ifnull(
                json_extract_scalar(payload, '$._protocol'),
                ifnull(
                    nullif(
                        json_extract_scalar(payload, '$._tls_next_proto'), 'unknown'
                    ),
                    nullif(
                        concat(
                            'TLS ',
                            json_extract_scalar(payload, '$.response.httpVersion')
                        ),
                        'TLS '
                    )
                )
            ) is not null and json_extract(
                payload, '$._socket'
            ) is not null and date = '2021-07-01'
        group by client, page, socket
    ) b on (a.client = b.client and a.page = b.page and a.socket = b.socket)
where a.tlsversion is not null or b.tlsversion is not null
group by a.client, cdn, firsthtml
order by a.client desc, total desc
