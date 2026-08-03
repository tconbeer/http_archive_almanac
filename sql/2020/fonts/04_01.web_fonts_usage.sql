# standardSQL
# web_fonts_usage
select
    if(ends_with(_table_suffix, 'desktop'), 'desktop', 'mobile') as client,
    regexp_replace(_table_suffix, r'(\d+)_(\d+)_(\d+).*', r'\1-\2-\3') as date,
    countif(reqfont > 0) as freq_fonts,
    count(0) as total,
    countif(reqfont > 0) / count(0) as pct_fonts
from `httparchive.summary_pages.*`
where reqfont is not null and bytesfont is not null
group by client, date
order by date desc, client
