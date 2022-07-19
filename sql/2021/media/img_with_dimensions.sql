# standardSQL
# usage meta open graph
# extracts the data about width, height and alt from the new customer metric
# using this, counts and reports on the usage for each attribute
create temporary function get_image_info(responsivestring string)
returns array < struct < haswidth int64,
hasheight int64,
hasalt int64,
hasreservedlayoutdimension int64
>> language js as '''
try {
  let result = Array()
  const responsiveImages = JSON.parse(responsiveString)
  if(responsiveImages &&  responsiveImages['responsive-images']){
  for(const image of responsiveImages["responsive-images"]){
    result.push({
      hasWidth: image.hasWidth ? 1 : 0,
      hasHeight: image.hasHeight ? 1 : 0,
      hasAlt: image.hasAlt ? 1 : 0,
      hasReservedLayoutDimension: image.reservedLayoutDimensions ? 1 : 0
    })
  }}
  return result
} catch(e) {
  return [];
}
'''
;

select
    client,
    count(0) as images,
    countif(haswidth = 1) as haswidth,
    countif(hasheight = 1) as hasheight,
    countif(hasalt = 1) as hasalt,
    countif(hasreservedlayoutdimension = 1) as hasdimensions,
    safe_divide(countif(haswidth = 1), count(0)) as perchaswidth,
    safe_divide(countif(hasheight = 1), count(0)) as perchasheight,
    safe_divide(countif(hasalt = 1), count(0)) as perchasalt,
    safe_divide(countif(hasreservedlayoutdimension = 1), count(0)) as perchasdimensions
from
    (
        select
            _table_suffix as client,
            haswidth,
            hasheight,
            hasalt,
            hasreservedlayoutdimension
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(get_image_info(json_value(payload, '$._responsive_images')))
    )
group by client
