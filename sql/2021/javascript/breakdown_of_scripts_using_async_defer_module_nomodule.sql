# standardSQL
# Breakdown of scripts using Async, Defer, Module or NoModule attributes.  Also
# breakdown of inline vs external scripts
CREATE TEMPORARY FUNCTION getScripts(payload STRING)
RETURNS STRUCT<total INT64, inline INT64, src INT64, async INT64, defer INT64, async_and_defer INT64, type_module INT64, nomodule INT64>
LANGUAGE js AS '''
try {
  var $ = JSON.parse(payload);
  var javascript = JSON.parse($._javascript);
  return javascript.script_tags;
} catch (e) {
  return {};
}
''';

select
    client,
    sum(script.total) as total_scripts,
    sum(script.inline) as inline_script,
    sum(script.src) as external_script,
    sum(script.src) / sum(script.total) as pct_external_script,
    sum(script.inline) / sum(script.total) as pct_inline_script,
    sum(script.async) as async,
    sum(script.defer) as defer,
    sum(script.async_and_defer) as async_and_defer,
    sum(script.type_module) as module,
    sum(script.nomodule) as nomodule,
    sum(script.async) / sum(script.src) as pct_external_async,
    sum(script.defer) / sum(script.src) as pct_external_defer,
    sum(script.async_and_defer) / sum(script.src) as pct_external_async_defer,
    sum(script.type_module) / sum(script.src) as pct_external_module,
    sum(script.nomodule) / sum(script.src) as pct_external_nomodule
from
    (
        select _table_suffix as client, getscripts(payload) as script
        from `httparchive.pages.2021_07_01_*`
    )
group by client
