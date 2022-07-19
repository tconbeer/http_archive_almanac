# standardSQL
# 01_12: Percent of pages that include script[type=module]
select
    _table_suffix as client,
    round(
        countif(
            json_extract_scalar(
                json_extract_scalar(payload, '$._almanac'), "$['01.12']"
            )
            = '1'
        )
        * 100
        / count(0),
        2
    ) as pct_module
from `httparchive.pages.2019_07_01_*`
group by client
