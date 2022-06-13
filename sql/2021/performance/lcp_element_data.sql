# standardSQL
# LCP element node details
create temp function getloadingattr(attributes string) returns string language js
as '''
  try {
    const data = JSON.parse(attributes);
    const loadingAttr = data.find(attr => attr["name"] === "loading")
    return loadingAttr.value
  } catch (e) {
    return "";
  }
'''
;

create temp function getdecodingattr(attributes string) returns string language js
as '''
  try {
    const data = JSON.parse(attributes);
    const decodingAttr = data.find(attr => attr["name"] === "decoding")
    return decodingAttr.value
  } catch (e) {
    return "";
  }
'''
;

create temp function getloadingclasses(attributes string) returns string language js
as '''
  try {
    const data = JSON.parse(attributes);
    const classes = data.find(attr => attr["name"] === "class").value
    if (classes.indexOf('lazyload') !== -1) {
        return classes
    } else {
        return ""
    }
  } catch (e) {
    return "";
  }
'''
;

with
    lcp_stats as (
        select
            _table_suffix as client,
            url,
            json_extract_scalar(
                payload, '$._performance.lcp_elem_stats[0].nodeName'
            ) as nodename,
            json_extract_scalar(
                payload, '$._performance.lcp_elem_stats[0].url'
            ) as elementurl,
            cast(
                json_extract_scalar(
                    payload, '$._performance.lcp_elem_stats[0].size'
                ) as int64
            ) as size,
            cast(
                json_extract_scalar(
                    payload, '$._performance.lcp_elem_stats[0].loadTime'
                ) as float64
            ) as loadtime,
            cast(
                json_extract_scalar(
                    payload, '$._performance.lcp_elem_stats[0].startTime'
                ) as float64
            ) as starttime,
            cast(
                json_extract_scalar(
                    payload, '$._performance.lcp_elem_stats[0].renderTime'
                ) as float64
            ) as rendertime,
            json_extract(
                payload, '$._performance.lcp_elem_stats[0].attributes'
            ) as attributes,
            getloadingattr(
                json_extract(payload, '$._performance.lcp_elem_stats[0].attributes')
            ) as loading,
            getdecodingattr(
                json_extract(payload, '$._performance.lcp_elem_stats[0].attributes')
            ) as decoding,
            getloadingclasses(
                json_extract(payload, '$._performance.lcp_elem_stats[0].attributes')
            ) as classwithlazyload
        from `httparchive.pages.2021_07_01_*`
    )

select
    client,
    nodename,
    count(distinct url) as pages,
    any_value(total) as total,
    count(distinct url) / any_value(total) as pct,
    countif(elementurl != '') as haveimages,
    countif(elementurl != '') / count(distinct url) as pct_haveimages,
    countif(loading = 'eager') as native_eagerload,
    countif(loading = 'lazy') as native_lazyload,
    countif(classwithlazyload != '') as lazyload_class,
    countif(classwithlazyload != '' or loading = 'lazy') as probably_lazyloaded,
    countif(classwithlazyload != '' or loading = 'lazy') / count(
        distinct url
    ) as pct_prob_lazyloaded,
    countif(decoding = 'async') as async_decoding,
    countif(decoding = 'sync') as sync_decoding,
    countif(decoding = 'auto') as auto_decoding
from lcp_stats
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2021_07_01_*`
        group by _table_suffix
    )
    using
    (client)
group by client, nodename
having pages > 1000
order by pct desc
