# standardSQL
# A summary count of the pages run against
select
    client,
    countif(success is not null) as success,
    countif(errors is not null) as errors,
    countif(success is not null and errors is null) as success_no_errors,
    countif(errors is not null and success is null) as errors_no_success,
    countif(success is not null and errors is not null) as success_errors,
    countif(success is null and errors is null) as no_success_no_errors,
    countif(success is not null) / count(0) as pct_success,
    countif(errors is not null) / count(0) as pct_errors,
    countif(success is not null and errors is null) / count(0) as pct_success_no_errors,
    countif(errors is not null and success is null) / count(0) as pct_errors_no_success,
    countif(success is not null and errors is not null)
    / count(0) as pct_success_errors,
    countif(success is null and errors is null) / count(0) as pct_no_success_no_errors
from
    (
        select
            client,
            json_extract(structured_data, '$.structured_data') as success,
            json_extract(structured_data, '$.log') as errors
        from
            (
                select
                    _table_suffix as client,
                    json_value(
                        json_extract(payload, '$._structured-data')
                    ) as structured_data
                from `httparchive.pages.2021_07_01_*`
            )
    )
group by client
order by client
