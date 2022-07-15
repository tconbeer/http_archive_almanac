# standardSQL
# 01_13: Percent of pages that include script[nomodule]
select
    _table_suffix as client,
    round(
        countif(
            json_extract_scalar(
                json_extract_scalar(payload, '$._almanac'), "$['01.13']"
            )
            = '1'
        )
        * 100 / count(
            0
        ),
        2
    ) as pct_nomodule
from `httparchive.pages.2019_07_01_*`
group by client
