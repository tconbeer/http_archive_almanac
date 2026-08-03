# standardSQL
# Percent of pages with fingerprint.js library
with
    requests as (
        select _table_suffix as client, page, url
        from `httparchive.requests.2020_08_01_*`
    ),

    base as (
        select
            client,
            count(distinct page) as total_pages,
            count(
                distinct if(
                    url like '%fingerprint2.min.js%' or url like '%fingerprintjs2%',
                    page,
                    null
                )
            ) as fingerprint_pages
        from requests
        group by client
    )

select
    client,
    total_pages,
    fingerprint_pages,
    fingerprint_pages / total_pages as pct_fingerprint_pages
from base
