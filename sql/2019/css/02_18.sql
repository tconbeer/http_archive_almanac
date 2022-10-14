# standardSQL
# 02_18: % of pages using all/print/screen/speech in media queries
CREATE TEMPORARY FUNCTION getMediaType(css STRING)
RETURNS STRUCT<all_media BOOLEAN, print_media BOOLEAN, screen_media BOOLEAN, speech_media BOOLEAN> LANGUAGE js AS '''
try {
  var reduceValues = (values, rule) => {
    if (rule.type != 'media') {
      return values;
    }

    var media = rule.media.toLowerCase();
    var types = ['all', 'print', 'screen', 'speech'];
    types.forEach(type => {
      if (media.includes(type)) {
        values[type + '_media'] = true;
      }
    });

    return values;
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, {});
} catch (e) {
  return {};
}
''';

select
    client,
    countif(all_media > 0) as freq_all,
    countif(print_media > 0) as freq_print,
    countif(screen_media > 0) as freq_screen,
    countif(speech_media > 0) as freq_speech,
    total,
    round(countif(all_media > 0) * 100 / total, 2) as pct_all,
    round(countif(print_media > 0) * 100 / total, 2) as pct_print,
    round(countif(screen_media > 0) * 100 / total, 2) as pct_screen,
    round(countif(speech_media > 0) * 100 / total, 2) as pct_speech
from
    (
        select
            client,
            countif(type.all_media) as all_media,
            countif(type.print_media) as print_media,
            countif(type.screen_media) as screen_media,
            countif(type.speech_media) as speech_media
        from
            (
                select client, page, getmediatype(css) as type
                from `httparchive.almanac.parsed_css`
                where date = '2019-07-01'
            )
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by client
    ) using (client)
group by client, total
