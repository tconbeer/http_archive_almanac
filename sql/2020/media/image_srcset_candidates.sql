# standardSQL
# images srcset candidates average
# returns all the data we need from _media
CREATE TEMPORARY FUNCTION get_media_info(media_string STRING)
RETURNS STRUCT<
  num_srcset_all INT64,
  num_srcset_candidates_avg INT64
> LANGUAGE js AS '''
var result = {};
try {
    var media = JSON.parse(media_string);

    if (Array.isArray(media) || typeof media != 'object') return result;

    result.num_srcset_all = media.num_srcset_all;
    result.num_srcset_candidates_avg =
      media.num_srcset_all == 0? 0: (media.num_srcset_candidates / media.num_srcset_all);

} catch (e) {}
return result;
''';

select
    client,
    safe_divide(
        countif(media_info.num_srcset_all > 0), count(0)
    ) as pages_with_srcset_pct,
    safe_divide(
        countif(
            media_info.num_srcset_candidates_avg >= 1
            and media_info.num_srcset_candidates_avg <= 3
        ),
        countif(media_info.num_srcset_all > 0)
    ) as pages_with_srcset_candidates_1_3_pct,
    safe_divide(
        countif(
            media_info.num_srcset_candidates_avg >= 1
            and media_info.num_srcset_candidates_avg <= 5
        ),
        countif(media_info.num_srcset_all > 0)
    ) as pages_with_srcset_candidates_1_5_pct,
    safe_divide(
        countif(
            media_info.num_srcset_candidates_avg > 5
            and media_info.num_srcset_candidates_avg <= 10
        ),
        countif(media_info.num_srcset_all > 0)
    ) as pages_with_srcset_candidates_5_10_pct,
    safe_divide(
        countif(
            media_info.num_srcset_candidates_avg > 10
            and media_info.num_srcset_candidates_avg <= 15
        ),
        countif(media_info.num_srcset_all > 0)
    ) as pages_with_srcset_candidates_10_15_pct,
    safe_divide(
        countif(
            media_info.num_srcset_candidates_avg > 15
            and media_info.num_srcset_candidates_avg <= 20
        ),
        countif(media_info.num_srcset_all > 0)
    ) as pages_with_srcset_candidates_15_20_pct
from
    (
        select
            _table_suffix as client,
            get_media_info(json_extract_scalar(payload, '$._media')) as media_info
        from `httparchive.pages.2020_08_01_*`
    )
group by client
order by client
