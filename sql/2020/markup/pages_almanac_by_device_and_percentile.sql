# standardSQL
# percientile data from almanac per device
# live run estimated $4.08 and took 2 min 28 sec
# returns all the data we need from _almanac
create temporary function get_almanac_info(almanac_string string)
returns struct < scripts_total int64,
none_jsonld_scripts_total int64,
src_scripts_total int64,
inline_scripts_total int64
> language js
as '''
var result = {};
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return result;

    if (almanac.scripts) {
      result.scripts_total = almanac.scripts.total;
      if (almanac.scripts.nodes) {
        result.none_jsonld_scripts_total = almanac.scripts.nodes.filter(n => !n.type || n.type.trim().toLowerCase() !== 'application/ld+json').length;
        result.src_scripts_total = almanac.scripts.nodes.filter(n => n.src && n.src.trim().length > 0).length;

        result.inline_scripts_total = result.none_jsonld_scripts_total - result.src_scripts_total;
      }
    }

} catch (e) {}
return result;
'''
;

select
    percentile,
    client,
    count(distinct url) as total,

    # scripts per page
    approx_quantiles(
        almanac_info.none_jsonld_scripts_total, 1000) [offset (percentile * 10)
    ] as none_jsonld_scripts_count_m205,

    # inline scripts ex jsonld
    approx_quantiles(
        almanac_info.inline_scripts_total, 1000) [offset (percentile * 10)
    ] as inline_scripts_count_m207,

    # src scripts
    approx_quantiles(
        almanac_info.src_scripts_total, 1000) [offset (percentile * 10)
    ] as src_scripts_count_m209

from
    (
        select
            _table_suffix as client,
            percentile,
            url,
            get_almanac_info(json_extract_scalar(payload, '$._almanac')) as almanac_info
        from
            `httparchive.pages.2020_08_01_*`,
            unnest( [10, 25, 50, 75, 90]) as percentile
    )
group by percentile, client
order by percentile, client
