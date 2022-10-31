# standardSQL
# Audio elements attribute usage
create temporary function getusedattributes(payload string)
returns array<string>
language js
as '''
try {
  const almanac = JSON.parse(payload);
  return Object.keys(almanac.audios.attribute_usage_count);
} catch (e) {
  return [];
}
'''
;
select
    client,
    total_sites,

    total_sites_with_audio,
    pct_sites_with_audio,

    attribute,
    count(0) as total_sites_using,
    # Of sites with audio tags, how often is this attribute used
    count(0) / total_sites_with_audio as pct_of_sites_using_audio
from
    `httparchive.pages.2021_07_01_*`,
    unnest(getusedattributes(json_extract_scalar(payload, '$._almanac'))) as attribute
left join
    (
        select
            client,
            count(0) as total_sites,
            countif(total_audios > 0) as total_sites_with_audio,
            countif(total_audios > 0) / count(0) as pct_sites_with_audio
        from
            (
                select
                    _table_suffix as client,
                    cast(
                        json_extract_scalar(
                            json_extract_scalar(payload, '$._almanac'), '$.audios.total'
                        ) as int64
                    ) as total_audios
                from `httparchive.pages.2021_07_01_*`
            )
        group by client
    )
    on (_table_suffix = client)
group by client, attribute, total_sites, total_sites_with_audio, pct_sites_with_audio
having total_sites_using >= 10
order by pct_of_sites_using_audio desc
