# standardSQL
# 04_03: Image Frequency by MimeType
select
    client,
    webimagetype as imagetype,
    count(0) as pagecount,
    countif(hits > 0) as frequencycount,
    round(100 * countif(hits > 0) / count(0), 2) as pct,
    sum(hits) as totalhits,
    sum(bytes) as totalbytes,
    approx_quantiles(hits, 1000) [offset (100)] as hits_p10,
    approx_quantiles(hits, 1000) [offset (250)] as hits_p25,
    approx_quantiles(hits, 1000) [offset (500)] as hits_p50,
    approx_quantiles(hits, 1000) [offset (750)] as hits_p75,
    approx_quantiles(hits, 1000) [offset (900)] as hits_p90,
    approx_quantiles(hits, 1000) [offset (990)] as hits_p99,
    approx_quantiles(bytes, 1000) [offset (100)] as bytes_p10,
    approx_quantiles(bytes, 1000) [offset (250)] as bytes_p25,
    approx_quantiles(bytes, 1000) [offset (500)] as bytes_p50,
    approx_quantiles(bytes, 1000) [offset (750)] as bytes_p75,
    approx_quantiles(bytes, 1000) [offset (900)] as bytes_p90,
    approx_quantiles(bytes, 1000) [offset (990)] as bytes_p99
from
    (
        select
            client,
            page,
            webimagetype,
            sum(if(lower(imagetype) = lower(webimagetype), hits, 0)) as hits,
            sum(if(lower(webimagetype) = lower(imagetype), bytes, 0)) as bytes
        from
            (
                select
                    client,
                    page,
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
                    count(0) as hits,
                    sum(respsize) as bytes
                from `httparchive.almanac.requests3`

                where
                    # many 404s ANDredirects show up as image/gif
                    status = 200 and

                    # we are trying to catch images. WPO populates the format for
                    # media but it uses a file extension guess.
                    # So we exclude mimetypes that aren't image or where the format
                    # couldn't be guessed by WPO
                    (format != '' or mimetype like 'image%') and

                    # many image/gifs are really beacons with 1x1 pixel, but svgs can
                    # get caught in the mix
                    (respsize > 1500 or regexp_contains(mimetype, r'svg')) and

                    # strip favicon requests
                    # strip video mimetypes ANDother favicons
                    format != 'ico' and not regexp_contains(mimetype, r'video|ico')
                group by client, page, imagetype
            )
        cross join unnest( ['jpg', 'png', 'webp', 'gif', 'svg']) as webimagetype
        group by client, page, webimagetype
    )
group by client, imagetype
order by client desc, totalhits desc
