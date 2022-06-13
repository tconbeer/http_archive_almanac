# standardSQL
# Percent of pages with IAB Transparency & Consent Framework
with
    pages_privacy as (
        select
            _table_suffix as client,
            json_extract_scalar(payload, '$._privacy') as metrics
        from `httparchive.pages.2020_08_01_*`
    )

select
    client,
    count(0) as total_websites,
    countif(json_extract_scalar(metrics, '$.iab_tcf') = '1') as websites_with_iab,
    countif(json_extract_scalar(metrics, '$.iab_tcf') = '1') / count(
        0
    ) as pct_iab_banner_pages
from pages_privacy
group by client
