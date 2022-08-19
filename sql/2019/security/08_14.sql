# standardSQL
# 08_14: Frame-ancestor CSP directive
select
    client,
    csp_frame_ancestors_count,
    csp_frame_ancestors_none_count,
    csp_frame_ancestors_self_count,
    total,
    round(csp_frame_ancestors_count * 100 / total, 2) as pct_csp_frame_ancestors,
    round(
        csp_frame_ancestors_none_count * 100 / total, 2
    ) as pct_csp_frame_ancestors_none,
    round(
        csp_frame_ancestors_self_count * 100 / total, 2
    ) as pct_csp_frame_ancestors_self
from
    (
        select
            client,
            count(0) as total,
            countif(
                regexp_contains(lower(respotherheaders), r'frame-ancestors')
                and regexp_contains(
                    lower(respotherheaders), 'content-security-policy ='
                )
            ) as csp_frame_ancestors_count,
            countif(
                regexp_contains(lower(respotherheaders), r'content-security-policy =')
                and ends_with(
                    regexp_extract(respotherheaders, r'(?i)\Wframe-ancestors([^,|;]+)'),
                    "'none'"
                )
            ) as csp_frame_ancestors_none_count,
            countif(
                regexp_contains(lower(respotherheaders), r'content-security-policy =')
                and ends_with(
                    regexp_extract(respotherheaders, r'(?i)\Wframe-ancestors([^,|;]+)'),
                    "'self'"
                )
            ) as csp_frame_ancestors_self_count
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and firsthtml
        group by client
    )
