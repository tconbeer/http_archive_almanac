# standardSQL
# usage of alt text in images
CREATE TEMPORARY FUNCTION get_markup_info(markup_string STRING)
RETURNS STRUCT<
  total INT64,
  alt_missing INT64,
  alt_blank INT64,
  alt_present INT64,
  decode_lazy INT64
> LANGUAGE js AS '''
var result = {};
try {
    var markup = JSON.parse(markup_string);

    if (Array.isArray(markup) || typeof markup != 'object') return result;

    result.total = markup.images.img.total;
    result.alt_missing = markup.images.img.alt.missing;
    result.alt_blank = markup.images.img.alt.blank;
    result.alt_present = markup.images.img.alt.present;
    result.decode_lazy = markup.images.img.decoding || 0;

} catch (e) {}
return result;
''';

select
    client,
    safe_divide(countif(markup_info.total > 0), count(0)) as pages_with_img_pct,
    safe_divide(
        countif(markup_info.alt_missing > 0), count(0)
    ) as pages_with_alt_missing_pct,
    safe_divide(
        countif(markup_info.alt_blank > 0), count(0)
    ) as pages_with_alt_blank_pct,
    safe_divide(
        countif(markup_info.alt_present > 0), count(0)
    ) as pages_with_alt_present_pct,
    sum(markup_info.total) as img_total,
    safe_divide(
        sum(markup_info.alt_missing), sum(markup_info.total)
    ) as imgs_alt_missing_pct,
    safe_divide(
        sum(markup_info.alt_blank), sum(markup_info.total)
    ) as img_alt_blank_pct,
    safe_divide(
        sum(markup_info.alt_present), sum(markup_info.total)
    ) as img_alt_present_pct
from
    (
        select
            _table_suffix as client,
            url,
            get_markup_info(json_extract_scalar(payload, '$._markup')) as markup_info
        from `httparchive.pages.2021_07_01_*`
    )
group by client
order by client
