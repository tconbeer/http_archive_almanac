# standardSQL
# 04_03: Images by MimeType
select
    client,
    # we need to normalize the image filetype. However, content-type often lies, but
    # WPO uses extensions.
    # without running `identify` on each image bytes, we are going to try a sanitize
    # approach and fall back to WPOs file extension match
    # I found this less problematic than trying to do the inverse by selecting only
    # image/ results and falling back to WPO. It's a mess either way
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
                        mimetype, r'(?is).*image[/\\](?:x-)?|[\."]|[ +,;]+.*$', ''
                    ),
                    r'(?i)pjpeg|jpeg',
                    'jpg'
                )
            )
        ),
        ''
    ) as imagetype,
    -- NULLIF(IF(REGEX_CONTAINS(mimetype, r'(?is)^image/'),
    -- LOWER(REGEXP_REPLACE(REGEXP_REPLACE(mimetype, r'(?i)^image[/\\](?:x-)?|[\."]|[
    -- +,;].*$', ''), r'(?i)pjpeg|jpeg', 'jpg')), format), '') AS imageType,
    # A future iteration could try and use the initator_type. however again WPO is
    # very inconsistent with results and I dont' have time to debug
    -- json_extract_scalar(payload, '$._initiator_type'),
    # ideally we would use a normalized mimeType from `identify` or other magic byte
    # tool
    -- mimetype,
    count(0) as hits,
    round((count(0) * 100 / sum(count(0)) over (partition by client)), 2) as hits_pct,
    sum(respsize) as bytes,
    round(
        (sum(respsize) * 100 / sum(sum(respsize)) over (partition by client)), 2
    ) as bytes_pct,
    approx_quantiles(respsize, 1000)[offset(100)] as size_p10,
    approx_quantiles(respsize, 1000)[offset(250)] as size_p25,
    approx_quantiles(respsize, 1000)[offset(500)] as size_p50,
    approx_quantiles(respsize, 1000)[offset(750)] as size_p75,
    approx_quantiles(respsize, 1000)[offset(900)] as size_p90
from `httparchive.almanac.requests3`
where
    # many 404s and redirects show up as image/gif
    status = 200 and

    # we are trying to catch images. WPO populates the format for media but it uses a
    # file extension guess.
    # So we exclude mimetypes that aren't image or where the format couldn't be
    # guessed by WPO
    (format != '' or mimetype like 'image%') and

    # many image/gifs are really beacons with 1x1 pixel, but svgs can get caught in
    # the mix
    (respsize > 1500 or regexp_contains(mimetype, r'svg')) and

    # strip favicon requests
    # strip video mimetypes and other favicons
    format != 'ico' and not regexp_contains(mimetype, r'video|ico')
group by client, imagetype
order by client desc, hits desc
