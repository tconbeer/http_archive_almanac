# standardSQL
# images with covid in path - average size
select
    client,
    lower(ext) as ext,
    count(0) as ext_count,
    countif(
        regexp_contains(lower(url), r'[^/]*?[:]//[^/]*?/.*?covid')
    ) as ext_count_covid,
    safe_divide(sum(respsize), count(0)) as avg_size,
    safe_divide(
        sum(
            if(regexp_contains(lower(url), r'[^/]*?[:]//[^/]*?/.*?covid'), respsize, 0)
        ),
        countif(regexp_contains(lower(url), r'[^/]*?[:]//[^/]*?/.*?covid'))
    ) as avg_size_covid
from `httparchive.almanac.requests`
where date = '2020-08-01' and type = 'image'
group by client, ext
having ext_count_covid > 100
order by client, ext_count_covid desc
;
