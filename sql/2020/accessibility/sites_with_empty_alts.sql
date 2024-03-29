# standardSQL
# % of sites with empty alt tags
create temporary function getaltstats(payload string)
returns struct<has_alts bool, has_alt_of_zero_length bool>
language js
as '''
try {
  const almanac = JSON.parse(payload);
  const alt_lengths = almanac.images.alt_lengths;

  return {
    has_alts: alt_lengths.filter(l => l >= 0).length > 0,
    has_alt_of_zero_length: alt_lengths.indexOf(0) >= 0,
  };
} catch (e) {
  return {
    has_alts: false,
    has_alt_of_zero_length: false,
  };
}
'''
;

select
    client,
    countif(alt_stats.has_alts) as total_sites_with_alts,
    countif(alt_stats.has_alt_of_zero_length) as total_sites_with_zero_length_alt,

    countif(alt_stats.has_alt_of_zero_length)
    / countif(alt_stats.has_alts) as perc_sites_with_zero_length_alt
from
    (
        select
            _table_suffix as client,
            getaltstats(json_extract_scalar(payload, '$._almanac')) as alt_stats
        from `httparchive.pages.2020_08_01_*`
    )
group by client
