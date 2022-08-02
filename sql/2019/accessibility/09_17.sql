# standardSQL
# 09_17: % pages using tables with headings
create temporary function gettableinfo(payload string)
returns struct < has_table boolean,
has_th boolean
> language js as '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count);
  if (Array.isArray(elements) || typeof elements != 'object') {
    return {
      has_table: false,
      has_th: false
    };
  }

  return {
    has_table: !!elements.table,
    has_th: !!elements.th
  };
} catch (e) {
  return {
    has_table: false,
    has_th: false
  };
}
'''
;
select
    client,
    count(0) as total_pages,

    countif(table_info.has_table) as total_using_tables,

    countif(table_info.has_th) as total_th,
    countif(has_columnheader_role) as total_columnheader,
    countif(has_rowheader_role) as total_rowheader,
    countif(
        table_info.has_th or has_rowheader_role or has_columnheader_role
    ) as total_using_any,

    round(
        countif(table_info.has_table and table_info.has_th)
        * 100
        / countif(table_info.has_table),
        2
    ) as perc_with_th,
    round(
        countif(table_info.has_table and has_columnheader_role)
        * 100
        / countif(table_info.has_table),
        2
    ) as perc_with_columnheader,
    round(
        countif(table_info.has_table and has_rowheader_role)
        * 100
        / countif(table_info.has_table),
        2
    ) as perc_with_rowheader,
    round(
        countif(
            table_info.has_table
            and (table_info.has_th or has_rowheader_role or has_columnheader_role)
        )
        * 100
        / countif(table_info.has_table),
        2
    ) as perc_with_any
from
    (
        select
            client,
            page,
            regexp_contains(
                body, r'(?i)\brole=[\'"]?(columnheader)\b'
            ) as has_columnheader_role,
            regexp_contains(
                body, r'(?i)\brole=[\'"]?(rowheader)\b'
            ) as has_rowheader_role
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
join
    (
        select _table_suffix as client, url as page, gettableinfo(payload) as table_info
        from `httparchive.pages.2019_07_01_*`
    ) using (client, page)
group by client
