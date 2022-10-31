# standardSQL
# Pages that use device sensors (based on event listeners)
# https://stackoverflow.com/questions/65048929/bigquery-extract-keys-from-json-object-convert-json-from-object-to-key-value-a
create temp function jsontokeyvaluearray(input string)
returns
    array< struct<key string, value array<string >>> language js as """
  try {
    let json = JSON.parse(input ? input: "{}");
    return Object.keys(json).map(e => ({"key": e, "value": json[e]}));
  } catch (error) {
    return []
  }
"""
;

with
    pages_events as (
        select
            _table_suffix as client,
            url,
            json_query(payload, '$._event-names') as events
        from `httparchive.pages.2021_07_01_*`
    ),

    sites_and_events as (
        -- the home page that was crawled
        -- the url that added the event listener, can be scripts etc.
        -- the name of the event
        select client, site, url_and_events.key as url, event
        from
            (
                select
                    client, url as site, jsontokeyvaluearray(events) as events_per_site
                from pages_events
            ),
            unnest(events_per_site) url_and_events,
            unnest(url_and_events.value) event
    ),

    total_pages as (
        select _table_suffix as client, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    client,
    event,
    count(distinct site) as number_of_websites,
    count(distinct site) / total as pct_of_websites,
    count(distinct url) as number_of_urls
from sites_and_events
join total_pages using (client)
-- device* events, from
-- https://www.esat.kuleuven.be/cosic/publications/article-3078.pdf
where event like 'device%'
group by client, event, total
order by client, event
