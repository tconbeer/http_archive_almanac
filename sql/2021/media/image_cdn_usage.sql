# standardSQL
create temporary function get_images(images_string string)
returns array
< struct
< url string
>>
language js
as '''
var result = [];
try {
  var images = JSON.parse(images_string);
  for (const img of images){
    result.push({
      url: img.url
    })
  }
} catch (e) {}
return result;
'''
;

select
    client,
    count(distinct pageurl) as pages,
    count(0) as images,
    safe_divide(countif(imgcdn1), count(0)) as img_with_cdn1_pct,
    safe_divide(countif(imgcdn2), count(0)) as img_with_cdn2_pct
from
    (
        select
            _table_suffix as client,
            a.url as pageurl,
            imageurl.url,
            regexp_contains(imageurl.url, r'.*[,\/]w_\d+.*') as imgcdn1,
            regexp_contains(imageurl.url, r'\?.*w=.*') as imgcdn2
        from
            `httparchive.pages.2021_07_01_*` as a,
            unnest(get_images(json_extract_scalar(payload, '$._Images'))) as imageurl
    )
group by client
