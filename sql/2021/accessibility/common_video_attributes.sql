# standardSQL
# Video elements attribute usage
create temporary function getusedattributes(payload string)
returns array<string>
language js
as '''
try {
  const almanac = JSON.parse(payload);
  return Object.keys(almanac.videos.attribute_usage_count);
} catch (e) {
  return [];
}
'''
;
select
    client,
    total_sites,

    total_sites_with_video,
    pct_sites_with_video,

    attribute,
    count(0) as total_sites_using,
    # Of sites with video tags, how often is this attribute used
    count(0) / total_sites_with_video as pct_of_sites_using_video
from
    `httparchive.pages.2021_07_01_*`,
    unnest(getusedattributes(json_extract_scalar(payload, '$._almanac'))) as attribute
left join
    (
        select
            client,
            count(0) as total_sites,
            countif(total_videos > 0) as total_sites_with_video,
            countif(total_videos > 0) / count(0) as pct_sites_with_video
        from
            (
                select
                    _table_suffix as client,
                    cast(
                        json_extract_scalar(
                            json_extract_scalar(payload, '$._almanac'), '$.videos.total'
                        ) as int64
                    ) as total_videos
                from `httparchive.pages.2021_07_01_*`
            )
        group by client
    )
    on (_table_suffix = client)
group by client, attribute, total_sites, total_sites_with_video, pct_sites_with_video
having total_sites_using >= 10
order by pct_of_sites_using_video desc
