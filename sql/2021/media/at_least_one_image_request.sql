select
    _table_suffix as client,
    countif(reqimg > 0) as atleastoneimgreqcount,
    count(0) as total,
    safe_divide(countif(reqimg > 0), count(0)) as atleastoneimgreqpct
from `httparchive.summary_pages.2021_07_01_*`
group by client
