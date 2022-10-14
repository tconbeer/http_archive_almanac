# standardSQL
# SW install events
CREATE TEMPORARY FUNCTION getInstallEvents(payload STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
  var payloadJSON = JSON.parse(payload);

  /* YouTube iFrames account for a lot of these, so we exclude them */
  /* Cannot use filter as it is a complex object and not a straight array */
  function filterYouTube(info) {

    var objectKeys = Object.keys(info);
    objectKeys = objectKeys.trim().split(',');
    for(var i = 0; i < objectKeys.length; i++) {
        if(objectKeys[i].toLowerCase().includes('youtube')) {
            delete info[objectKeys[i]];
        }
    }
    return info;
  }

  var windowEventListenersInfo = Object.values(filterYouTube(payloadJSON.windowEventListenersInfo)).flat();
  var windowPropertiesInfo = Object.values(filterYouTube(payloadJSON.windowPropertiesInfo)).flat()

  return [...new Set([...windowEventListenersInfo ,...windowPropertiesInfo])];
} catch (e) {
  return [];
}
''';

select
    _table_suffix as client,
    install_event,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from
    `httparchive.pages.2021_07_01_*`,
    unnest(getinstallevents(json_extract(payload, '$._pwa'))) as install_event
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        -- This condition filters out tests that might have broken when running the
        -- 'pwa' metric
        -- as even pages without any pwa capabilities will have a _pwa object with
        -- empty fields
        where json_extract(payload, '$._pwa') != '[]'
        group by _table_suffix
    ) using (_table_suffix)
where
    (
        json_extract(payload, '$._pwa.windowEventListenersInfo') != '[]'
        or json_extract(payload, '$._pwa.windowPropertiesInfo') != '[]'
    )
    and install_event != ''
    and install_event != '[]'
group by client, total, install_event
order by freq / total desc, client
