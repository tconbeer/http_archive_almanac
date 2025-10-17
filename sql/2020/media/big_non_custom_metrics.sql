# standardSQL
# non custom metrics sql that uses regexp on response bodies
# img src vs data-uri
# count rel=preconnect
# video with src
# video with source
# figure
# figure with figcaption
select
    client,
    countif(has_img_data_uri) / countif(has_img_src) as pages_with_img_data_uri_pct,
    countif(rel_preconnect) / count(0) as pages_with_rel_preconnect_pct,
    countif(has_video_src) / count(0) as pages_with_video_src_pct,
    countif(has_video_source) / count(0) as pages_with_video_source_pct,
    countif(has_figure) / count(0) as pages_with_figure_pct,
    countif(has_figcaption) / count(0) as pages_with_figcaption_pct
from
    (
        select
            client,
            page,
            regexp_contains(
                body, r'(?i)<img[^><]*src=(?:\"|\')*data[:]image/(?:\"|\')*[^><]*>'
            ) as has_img_data_uri,
            regexp_contains(body, r'(?i)<img[^><]*src=[^><]*>') as has_img_src,
            regexp_contains(
                body, r'(?i)<link[^><]*rel=(?:\"|\')*preconnect(?:\"|\')*[^><]*>'
            ) as rel_preconnect,
            regexp_contains(body, r'(?i)<video[^><]*src=[^><]*>') as has_video_src,
            regexp_contains(
                body, r'(?i)<video[^><]*>.*?<source[^><]*>.*?</video>'
            ) as has_video_source,
            regexp_contains(body, r'(?i)<figure[^><]*>') as has_figure,
            regexp_contains(
                body, r'(?i)<figure[^><]*>.*?<figcaption[^><]*>.*?</figure>'
            ) as has_figcaption
        from `httparchive.almanac.summary_response_bodies`
        where date = '2020-08-01' and firsthtml
    )
group by client
order by client
