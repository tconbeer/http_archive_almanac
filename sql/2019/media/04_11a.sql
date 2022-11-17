# standardSQL
# 04_11a: Bytes per pixel per image format
create temporary function getimages(payload string)
returns
    array<
        struct<
            url string,
            naturalwidth int64,
            naturalheight int64,
            width int64,
            height int64
        >
    >
language js
as
    '''
try {
  var $ = JSON.parse(payload);
  var images = JSON.parse($._Images) || [];
  return images.map(({url, naturalHeight, naturalWidth, width, height}) => ({url, naturalHeight: Number.parseInt(naturalHeight) || 0, naturalWidth: Number.parseInt(naturalWidth) || 0, width: Number.parseInt(width) || 0, height: Number.parseInt(height) || 0}));
} catch (e) {}
return null;
'''
;

select
    a.client,
    imagetype,
    count(0) as count,
    approx_quantiles(if(imagetype = 'svg' and pixels > 0, pixels, naturalpixels), 1000)[
        offset(100)
    ] as pixels_p10,
    approx_quantiles(if(imagetype = 'svg' and pixels > 0, pixels, naturalpixels), 1000)[
        offset(250)
    ] as pixels_p25,
    approx_quantiles(if(imagetype = 'svg' and pixels > 0, pixels, naturalpixels), 1000)[
        offset(500)
    ] as pixels_p50,
    approx_quantiles(if(imagetype = 'svg' and pixels > 0, pixels, naturalpixels), 1000)[
        offset(750)
    ] as pixels_p75,
    approx_quantiles(if(imagetype = 'svg' and pixels > 0, pixels, naturalpixels), 1000)[
        offset(900)
    ] as pixels_p90,
    approx_quantiles(bytes, 1000)[offset(100)] as bytes_p10,
    approx_quantiles(bytes, 1000)[offset(250)] as bytes_p25,
    approx_quantiles(bytes, 1000)[offset(500)] as bytes_p50,
    approx_quantiles(bytes, 1000)[offset(750)] as bytes_p75,
    approx_quantiles(bytes, 1000)[offset(900)] as bytes_p90,
    approx_quantiles(
        round(bytes / if(imagetype = 'svg' and pixels > 0, pixels, naturalpixels), 4),
        1000
    )[offset(100)] as bpp_p10,
    approx_quantiles(
        round(bytes / if(imagetype = 'svg' and pixels > 0, pixels, naturalpixels), 4),
        1000
    )[offset(250)] as bpp_p25,
    approx_quantiles(
        round(bytes / if(imagetype = 'svg' and pixels > 0, pixels, naturalpixels), 4),
        1000
    )[offset(500)] as bpp_p50,
    approx_quantiles(
        round(bytes / if(imagetype = 'svg' and pixels > 0, pixels, naturalpixels), 4),
        1000
    )[offset(750)] as bpp_p75,
    approx_quantiles(
        round(bytes / if(imagetype = 'svg' and pixels > 0, pixels, naturalpixels), 4),
        1000
    )[offset(900)] as bpp_p90
from
    (
        select
            _table_suffix as client,
            p.url as page,
            image.url as url,
            image.width as width,
            image.height as height,
            image.naturalwidth as naturalwidth,
            image.naturalheight as naturalheight,
            ifnull(image.width, 0) * ifnull(image.height, 0) as pixels,
            ifnull(image.naturalwidth, 0)
            * ifnull(image.naturalheight, 0) as naturalpixels
        from `httparchive.pages.2019_07_01_*` p
        cross join unnest(getimages(payload)) as image
        where image.naturalheight > 0 and image.naturalwidth > 0
    -- LIMIT 1000
    ) a
left join
    (
        select
            client,
            page,
            url,
            nullif(
                if(
                    regex_contains(
                        mimetype,
                        r'(?i)^application|^applicaton|^binary|^image$|^multipart|^media|^$|^text/html|^text/plain|\d|array|unknown|undefined|\*|string|^img|^images|^text|\%2f|\(|ipg$|jpe$|jfif'
                    ),
                    format,
                    lower(
                        regexp_replace(
                            regexp_replace(
                                mimetype,
                                r'(?is).*image[/\\](?:x-)?|[\."]|[ +,;]+.*$',
                                ''
                            ),
                            r'(?i)pjpeg|jpeg',
                            'jpg'
                        )
                    )
                ),
                ''
            ) as imagetype,
            respsize as bytes
        from `httparchive.almanac.requests3`

        where
            # many 404s and redirects show up as image/gif
            status = 200 and

            # we are trying to catch images. WPO populates the format for media but it
            # uses a file extension guess.
            # So we exclude mimetypes that aren't image or where the format couldn't
            # be guessed by WPO
            (format != '' or mimetype like 'image%') and

            # many image/gifs are really beacons with 1x1 pixel, but svgs can get
            # caught in the mix
            (respsize > 1500 or regexp_contains(mimetype, r'svg')) and

            # strip favicon requests
            # strip video mimetypes and other favicons
            format != 'ico' and not regexp_contains(mimetype, r'video|ico')
    -- limit 1000
    )
    on (b.client = a.client and a.page = b.page and a.url = b.url)

where
    naturalpixels > 0
    and bytes > 0
    and imagetype in ('jpg', 'png', 'webp', 'gif', 'svg')
group by client, imagetype
order by client desc
