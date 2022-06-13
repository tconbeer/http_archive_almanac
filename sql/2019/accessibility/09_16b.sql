# standardSQL
# 09_16b: % page with forms using invalid/required
create temporary function gettotalinputsused(payload string)
returns int64 language js
as '''
  try {
    var $ = JSON.parse(payload);
    if (!$._element_count) {
      return 0;
    }

    var element_count = JSON.parse($._element_count);
    if (!element_count) {
      return 0;
    }

    return (element_count.input || 0) + (element_count.select || 0) + (element_count.textarea || 0);
  } catch (e) {
    return 0;
  }
'''
;

select
    client,
    count(0) as total_pages,
    countif(total_inputs > 0) as total_pages_with_inputs,
    countif(uses_aria_invalid) as total_with_aria_invalid,
    countif(uses_aria_required) as total_with_aria_required,
    countif(uses_required) as total_with_required,
    countif(uses_aria_required or uses_required) as total_with_either_required,

    round(countif(total_inputs > 0) * 100 / count(0), 2) as perc_pages_with_inputs,
    round(
        countif(uses_aria_invalid) * 100 / countif(total_inputs > 0), 2
    ) as perc_applicable_aria_invalid,
    round(
        countif(uses_aria_required) * 100 / countif(total_inputs > 0), 2
    ) as perc_applicable_aria_required,
    round(
        countif(uses_required) * 100 / countif(total_inputs > 0), 2
    ) as perc_applicable_required,
    round(
        countif(uses_aria_required or uses_required) * 100 / countif(total_inputs > 0),
        2
    ) as perc_applicable_either_required
from
    (
        select
            client,
            page,
            regexp_contains(body, '<input[^>]+aria-invalid\\b') as uses_aria_invalid,
            regexp_contains(
                body, '<input[^>]+(aria-required)\\b'
            ) as uses_aria_required,
            regexp_contains(body, '<input[^>]+[^-](required)\\b') as uses_required
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
join
    (
        select
            _table_suffix as client,
            url as page,
            gettotalinputsused(payload) as total_inputs
        from `httparchive.pages.2019_07_01_*`
    )
    using(client, page)
group by client
