create temporary function getsrcsetinfo(responsiveimagesjsonstring string)
returns array < struct < imgurl string,
approximateresourcewidth int64,
approximateresourceheight int64,
bytesize int64,
bitsperpixel numeric,
ispixel bool,
isdataurl bool,
resourceformat string
>> language js
as '''

function pithyType( { contentType, url } ) {
  const subtypeMap = {
      'svg+xml': 'svg',
      'svgz': 'svg',
      'jpeg': 'jpg',
      'jfif': 'jpg',
      'x-png': 'png',
      'vnd.microsoft.icon': 'ico',
      'x-icon': 'ico',
      'jxr': 'jxr',
      'vnd.ms-photo': 'jxr',
      'hdp': 'jxr',
      'wdp': 'jxr',
      'jpf': 'jp2',
      'jpx': 'jp2',
      'jpm': 'jp2',
      'mj2': 'jp2',
      'x-jp2-container': 'jp2',
      'x-jp2-codestream': 'jp2',
      'x-jpeg2000-image': 'jp2',
      'heic': 'heif',
      'x-ms-bmp': 'bmp',
      'x-pict': 'pict',
      'tif': 'tiff',
      'x-tif': 'tiff',
      'x-tiff': 'tiff',
      'vnd.mozilla.apng': 'apng',
      // identities
      'apng': 'apng',
      'jpg': 'jpg',
      'jp2': 'jp2',
      'png': 'png',
      'gif': 'gif',
      'ico': 'ico',
      'webp': 'webp',
      'avif': 'avif',
      'tiff': 'tiff',
      'flif': 'flif',
      'heif': 'heif',
      'jxl': 'jxl',
      'avif-sequence': 'avif-sequence', // keep separate from single frames...
      'heic-sequence': 'heic-sequence',
      'bmp': 'bmp',
      'pict': 'pict'
  };

  function normalizeSubtype( subtype ) {
      if ( subtypeMap[ subtype ] ) {
          return subtypeMap[ subtype ];
      }
      return 'unknown'; // switch between:
                        // `subtype`
                        //     to see everything, check if there's anything else worth capturing
                        // `'unknown'`
                        //     to make results manageable
  }

  // if it's a data url, take the mime type from there, done.
  if ( url &&
        typeof url === "string" ) {
      const match = url.toLowerCase().match( /^data:image\\/([\\w\\-\\.\\+]+)/ );
      if ( match && match[ 1 ] ) {
          return normalizeSubtype( match[ 1 ] );
      }
  }

  // if we get a content-type header, use it!
  if ( contentType &&
        typeof contentType === "string" ) {
      const match = contentType.toLowerCase().match( /image\\/([\\w\\-\\.\\+]+)/ );
      if ( match && match[ 1 ] ) {
          return normalizeSubtype( match[ 1 ] );
      }
  }

  // otherwise fall back to extension in the URL
  if ( url &&
        typeof url === "string" ) {
      const splitOnSlashes = url.split("/");
      if ( splitOnSlashes.length > 1 ) {
          const afterLastSlash = splitOnSlashes[ splitOnSlashes.length - 1 ],
                splitOnDots = afterLastSlash.split(".");
          if ( splitOnDots.length > 1 ) {
              return normalizeSubtype(
                  splitOnDots[ splitOnDots.length - 1 ]
                    .toLowerCase()
                    .replace( /^(\\w+)[\\?\\&\\#].*/, '$1' ) // strip query params
              );
          }
      }
  }

  // otherwise throw up our hands
  return 'unknown';
  }

  const parsed = JSON.parse( responsiveImagesJsonString );
  if ( parsed && parsed.map ) {
        const dataRegEx = new RegExp('^data');
    return parsed.map( d => ({
            imgURL: d.url,
            approximateResourceWidth: Math.floor( d.approximateResourceWidth || 0 ),
            approximateResourceHeight: Math.floor( d.approximateResourceHeight || 0 ),
            byteSize: Math.floor( d.byteSize || 0 ),
            bitsPerPixel: parseFloat( d.bitsPerPixel || 0 ),
            isPixel: d.approximateResourceWidth == 1 && d.approximateResourceHeight == 1,
            isDataURL: dataRegEx.test(d.url),
            resourceFormat: pithyType({ contentType: d.mimeType, url: d.url })
    }) );
    }
'''
;

with
    imgs as (
        select
            _table_suffix as client,
            url as pageurl,
            imgurl,
            approximateresourcewidth,
            approximateresourceheight,
            bytesize,
            bitsperpixel,
            ispixel,
            isdataurl,
            (approximateresourcewidth * approximateresourceheight)
            / 1000000 as megapixels,
            (approximateresourcewidth / approximateresourceheight) as aspectratio,
            resourceformat
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(
                getsrcsetinfo(
                    json_query(
                        json_value(payload, '$._responsive_images'),
                        '$.responsive-images'
                    )
                )
            )
    ),

    percentiles as (
        select
            client,
            approx_quantiles(
                approximateresourcewidth, 1000
            ) as resourcewidthpercentiles,
            approx_quantiles(
                approximateresourceheight, 1000
            ) as resourceheightpercentiles,
            approx_quantiles(aspectratio, 1000) as aspectratiopercentiles,
            approx_quantiles(megapixels, 1000) as megapixelspercentiles,
            approx_quantiles(bytesize, 1000) as bytesizepercentiles,
            approx_quantiles(bitsperpixel, 1000) as bitsperpixelpercentiles,
            count(0) as imgcount
        from imgs
        where approximateresourcewidth > 1 and approximateresourceheight > 1
        group by client
    )

select
    percentile,
    client,
    imgcount,
    resourcewidthpercentiles[offset(percentile * 10)] as resourcewidth,
    resourceheightpercentiles[offset(percentile * 10)] as resourceheight,
    aspectratiopercentiles[offset(percentile * 10)] as aspectratio,
    megapixelspercentiles[offset(percentile * 10)] as megapixels,
    bytesizepercentiles[offset(percentile * 10)] as bytesize,
    bitsperpixelpercentiles[offset(percentile * 10)] as bitsperpixel
from percentiles, unnest([0, 10, 25, 50, 75, 90, 100]) as percentile
order by imgcount desc, percentile
