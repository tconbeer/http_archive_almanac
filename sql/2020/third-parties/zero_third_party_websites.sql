# standardSQL
# Websites with no third party requests
# Provides incorrect information in some cases, e.g. pageid = 140607555
with
    requests as (
        select _table_suffix as client, pageid as page, crawlid, req_host as host
        from `httparchive.summary_requests.2020_08_01_*`
    ),

    pages as (
        select _table_suffix as client, pageid, crawlid, wptid, reqtotal, url
        from `httparchive.summary_pages.2020_08_01_*`
    ),

    base as (
        select
            logical_and(net.host(host) = net.host(url)) as zero_third_party,
            url,
            requests.crawlid as requests_crawl,
            pages.crawlid as pages_crawl,
            wptid,
            reqtotal
        from requests
        join pages on requests.page = pages.pageid
        group by url, requests_crawl, pages_crawl, wptid, reqtotal
        having zero_third_party = true

    )

select url, requests_crawl, pages_crawl, wptid, reqtotal
from base
order by reqtotal desc
