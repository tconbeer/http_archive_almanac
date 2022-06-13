# standardSQL
# Breakdown of scripts using Async, Defer, Module or NoModule attributes.  Also
# breakdown of inline vs external scripts
select
    _table_suffix as client,
    countif(
        cast(
            json_extract(
                json_extract_scalar(payload, '$._javascript'), '$.script_tags.async'
            ) as int64
        ) > 0
    ) as async,
    countif(
        cast(
            json_extract(
                json_extract_scalar(payload, '$._javascript'), '$.script_tags.defer'
            ) as int64
        ) > 0
    ) as defer,
    countif(
        cast(
            json_extract(
                json_extract_scalar(payload, '$._javascript'),
                '$.script_tags.async_and_defer'
            ) as int64
        ) > 0
    ) as async_and_defer,
    countif(
        cast(
            json_extract(
                json_extract_scalar(payload, '$._javascript'),
                '$.script_tags.type_module'
            ) as int64
        ) > 0
    ) as module,
    countif(
        cast(
            json_extract(
                json_extract_scalar(payload, '$._javascript'), '$.script_tags.nomodule'
            ) as int64
        ) > 0
    ) as nomodule,
    countif(
        cast(
            json_extract(
                json_extract_scalar(payload, '$._javascript'), '$.script_tags.async'
            ) as int64
        ) > 0
    ) / count(0) as async_pct,
    countif(
        cast(
            json_extract(
                json_extract_scalar(payload, '$._javascript'), '$.script_tags.defer'
            ) as int64
        ) > 0
    ) / count(0) as defer_pct,
    countif(
        cast(
            json_extract(
                json_extract_scalar(payload, '$._javascript'),
                '$.script_tags.async_and_defer'
            ) as int64
        ) > 0
    ) / count(0) as async_and_defer_pct,
    countif(
        cast(
            json_extract(
                json_extract_scalar(payload, '$._javascript'),
                '$.script_tags.type_module'
            ) as int64
        ) > 0
    ) / count(0) as module_pct,
    countif(
        cast(
            json_extract(
                json_extract_scalar(payload, '$._javascript'), '$.script_tags.nomodule'
            ) as int64
        ) > 0
    ) / count(0) as nomodule_pct,
    countif(
        cast(
            json_extract(
                json_extract_scalar(payload, '$._javascript'), '$.script_tags.async'
            ) as int64
        ) = 0 and cast(
            json_extract(
                json_extract_scalar(payload, '$._javascript'), '$.script_tags.defer'
            ) as int64
        ) = 0
    ) as neither,
    countif(
        cast(
            json_extract(
                json_extract_scalar(payload, '$._javascript'), '$.script_tags.async'
            ) as int64
        ) = 0 and cast(
            json_extract(
                json_extract_scalar(payload, '$._javascript'), '$.script_tags.defer'
            ) as int64
        ) = 0
    ) / count(0) as neither_pct
from `httparchive.pages.2021_07_01_*`
group by client
