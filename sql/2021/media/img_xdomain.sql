# standardSQL
# Cross domain image requests
create temporary function get_images(images_string string)
returns array<struct<url string>>
language js
as '''
var result = [];
try {
  var images = JSON.parse(images_string);
  for (img of images){
    result.push({
      url: img.url
    });
  }
} catch (e) {}
return result;
'''
;
select
    client,
    count(distinct pageurl) as pages,
    count(0) as images,
    safe_divide(countif(pagedomain = imagedomain), count(0)) as img_xdomain_pct,
    safe_divide(countif(pagedomain != imagedomain), count(0)) as img_samedomain_pct
from
    (
        select
            _table_suffix as client,
            a.url as pageurl,
            format('%T', net.reg_domain(a.url)) as pagedomain,
            format('%T', net.reg_domain(imageurl.url)) as imagedomain
        from
            `httparchive.pages.2021_07_01_*` a,
            unnest(get_images(json_extract_scalar(payload, '$._Images'))) as imageurl
    )
group by client
