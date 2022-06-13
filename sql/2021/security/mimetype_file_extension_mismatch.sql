# standardSQL
# Prevalence of mimetype - file extension mismatches among all requests. Non-SVG
# images are ignored.
with
    mimtype_file_ext_pairs as (
        select
            client,
            lower(mimetype) as mimetype,
            lower(ext) as file_extension,
            sum(count(0)) over (partition by client) as total_requests,
            count(0) as count_pair
        from `httparchive.almanac.requests`
        where date = '2021-07-01'
        group by client, mimetype, file_extension
    )

select
    client,
    mimetype,
    file_extension,
    total_requests,
    sum(min(count_pair)) over (partition by client) as count_mismatches,
    sum(min(count_pair)) over (partition by client) / total_requests as pct_mismatches,
    min(count_pair) as count_pair,
    min(count_pair) / sum(min(count_pair)) over (partition by client) as pct_pair
from mimtype_file_ext_pairs
where
    mimetype is not null
    and mimetype != ''
    and file_extension is not null
    and file_extension != ''
    and mimetype not like concat('%', file_extension) and not (
        regexp_contains(
            mimetype, '(application|text)/(x-)*javascript'
        ) and regexp_contains(file_extension, r'(?i)^m?js$')
    ) and not (
        mimetype = 'image/svg+xml' and regexp_contains(file_extension, r'(?i)^svg$')
    ) and not (
        mimetype = 'audio/mpeg' and regexp_contains(file_extension, r'(?i)^mp3$')
    ) and not (
        starts_with(mimetype, 'image/') and regexp_contains(
            file_extension,
            r'(?i)^(apng|avif|bmp|cur|gif|jpeg|jpg|jfif|ico|pjpeg|pjp|png|tif|tiff|webp)$'
        )
    )
group by client, total_requests, mimetype, file_extension
order by count_pair desc
limit 100
