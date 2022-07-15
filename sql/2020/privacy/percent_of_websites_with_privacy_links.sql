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
    countif(
        cast(json_extract_scalar(metrics, '$.privacy_wording_links') as int64) > 0
    ) as websites_with_privacy_link,
    countif(cast(json_extract_scalar(metrics, '$.privacy_wording_links') as int64) > 0)
    / count(0) as pct_websites_with_privacy_link
from pages_privacy
group by client
