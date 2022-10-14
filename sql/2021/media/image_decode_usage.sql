# standardSQL
CREATE TEMPORARY FUNCTION get_decode_info(images_string STRING)
RETURNS STRUCT<
  total INT64,
  decode_async INT64
> LANGUAGE js AS '''
let result = {};
try {
  let images = JSON.parse(images_string);
  if (!Array.isArray(images)) {
      return {};
  }

  result.total = images.length;
  result.decode_async = 0;

  for(let img of images) {
      if(img.decoding === 'async'){
          result.decode_async += 1
      }
  }
} catch (e) {}
return result;
''';

select
    client,
    count(0) as pages_total,
    safe_divide(countif(images_info.total > 0), count(0)) as pages_with_img_pct,
    countif(images_info.decode_async > 0) as pages_with_decode_async,
    safe_divide(
        countif(images_info.decode_async > 0), count(0)
    ) as pages_with_decode_async_pct,
    sum(images_info.total) as img_total,
    sum(images_info.decode_async) as imgs_with_decode_async,
    safe_divide(
        sum(images_info.decode_async), sum(images_info.total)
    ) as imgs_with_decode_async_pct
from
    (
        select
            _table_suffix as client,
            url,
            get_decode_info(json_extract_scalar(payload, '$._Images')) as images_info
        from `httparchive.pages.2021_07_01_*`
    )
group by client
order by client
