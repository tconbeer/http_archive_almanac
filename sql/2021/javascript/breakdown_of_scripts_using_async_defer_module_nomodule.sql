# standardSQL
# Breakdown of scripts using Async, Defer, Module or NoModule attributes.  Also
# breakdown of inline vs external scripts
create temporary function getscripts(payload string)
returns
    struct<
        total int64,
        inline int64,
        src int64,
        async int64,
        defer int64,
        async_and_defer int64,
        type_module int64,
        nomodule int64
    >
language js
as '''
try {
  var $ = JSON.parse(payload);
  var javascript = JSON.parse($._javascript);
  return javascript.script_tags;
} catch (e) {
  return {};
}
'''
;

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
