# standardSQL
# A count of pages which include each type of structured data
select
    client,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.rdfa'
            ) as bool
        )
    ) as rdfa,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.json_ld'
            ) as bool
        )
    ) as json_ld,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.microdata'
            ) as bool
        )
    ) as microdata,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.microformats2'
            ) as bool
        )
    ) as microformats2,
    countif(
        cast(
            json_extract(
                structured_data,
                '$.structured_data.rendered.present.microformats_classic'
            ) as bool
        )
    ) as microformats_classic,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.dublin_core'
            ) as bool
        )
    ) as dublin_core,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.twitter'
            ) as bool
        )
    ) as twitter,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.facebook'
            ) as bool
        )
    ) as facebook,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.opengraph'
            ) as bool
        )
    ) as opengraph,
    countif(
        json_extract(structured_data, '$.structured_data') is not null and json_extract(
            structured_data, '$.log'
        ) is null
    ) as total_structured_data_ran,
    count(0) as total_pages,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.rdfa'
            ) as bool
        )
    ) / count(0) as pct_rdfa,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.json_ld'
            ) as bool
        )
    ) / count(0) as pct_json_ld,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.microdata'
            ) as bool
        )
    ) / count(0) as pct_microdata,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.microformats2'
            ) as bool
        )
    ) / count(0) as pct_microformats2,
    countif(
        cast(
            json_extract(
                structured_data,
                '$.structured_data.rendered.present.microformats_classic'
            ) as bool
        )
    ) / count(0) as pct_microformats_classic,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.dublin_core'
            ) as bool
        )
    ) / count(0) as pct_dublin_core,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.twitter'
            ) as bool
        )
    ) / count(0) as pct_twitter,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.facebook'
            ) as bool
        )
    ) / count(0) as pct_facebook,
    countif(
        cast(
            json_extract(
                structured_data, '$.structured_data.rendered.present.opengraph'
            ) as bool
        )
    ) / count(0) as pct_opengraph,
    countif(
        json_extract(structured_data, '$.structured_data') is not null and json_extract(
            structured_data, '$.log'
        ) is null
    ) / count(0) as pct_total_structured_data_ran
from
    (
        select
            _table_suffix as client,
            json_value(json_extract(payload, '$._structured-data')) as structured_data
        from `httparchive.pages.2021_07_01_*`
    )
group by client
order by client
