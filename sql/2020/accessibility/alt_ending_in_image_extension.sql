# standardSQL
# Alt text ending in an image extension
create temporary function getusedextensions(payload string)
returns array<struct<extension string, total int64>>
language js
as
    '''
try {
  const a11y = JSON.parse(payload);

  return Object.entries(a11y.file_extension_alts.file_extensions).map(([extension, total]) => {
    return {extension, total};
  });
} catch (e) {
  return [];
}
'''
;
select
    client,
    sites_with_non_empty_alt,
    sites_with_file_extension_alt,
    total_alts_with_file_extensions,

    # Of sites with a non-empty alt, what % have an alt with a file extension
    sites_with_file_extension_alt
    / sites_with_non_empty_alt as pct_sites_with_file_extension_alt,
    # Given a random alt, how often will it end in a file extension
    total_alts_with_file_extensions
    / total_non_empty_alts as pct_alts_with_file_extension,

    extension_stat.extension as extension,
    count(0) as total_sites_using,
    # Of sites with a non-empty alt, what % have an alt with this file extension
    count(0) / sites_with_non_empty_alt as pct_applicable_sites_using,

    # Of sites with a non-empty alt, what % have an alt with this file extension
    sum(extension_stat.total) as total_occurances,
    # Given a random alt ending in a file extension, how often will it end in this
    # file extension
    sum(extension_stat.total) / total_alts_with_file_extensions as pct_total_occurances
from
    `httparchive.pages.2020_08_01_*`,
    unnest(getusedextensions(json_extract_scalar(payload, '$._a11y'))) as extension_stat
left join
    (
        select
            client,
            countif(total_non_empty_alt > 0) as sites_with_non_empty_alt,
            countif(total_with_file_extension > 0) as sites_with_file_extension_alt,

            sum(total_non_empty_alt) as total_non_empty_alts,
            sum(total_with_file_extension) as total_alts_with_file_extensions
        from
            (
                select
                    _table_suffix as client,
                    cast(
                        json_extract_scalar(
                            json_extract_scalar(payload, '$._markup'),
                            '$.images.img.alt.present'
                        ) as int64
                    ) as total_non_empty_alt,
                    cast(
                        json_extract_scalar(
                            json_extract_scalar(payload, '$._a11y'),
                            '$.file_extension_alts.total_with_file_extension'
                        ) as int64
                    ) as total_with_file_extension
                from `httparchive.pages.2020_08_01_*`
            )
        group by client
    )
    on (_table_suffix = client)
group by
    client,
    sites_with_non_empty_alt,
    sites_with_file_extension_alt,
    total_non_empty_alts,
    total_alts_with_file_extensions,
    extension
order by client, total_occurances desc
