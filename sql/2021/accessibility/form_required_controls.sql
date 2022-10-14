# standardSQL
# Various stats for required form controls (form controls being: input, select,
# textarea)
CREATE TEMPORARY FUNCTION requiredControls(payload STRING)
RETURNS STRUCT<total INT64, asterisk INT64, required_attribute INT64, aria_required INT64, all_three INT64, asterisk_required INT64, asterisk_aria INT64, required_with_aria INT64> LANGUAGE js AS '''
  try {
    const a11y = JSON.parse(payload);
    const required_form_controls = a11y.required_form_controls

    const total = required_form_controls.length;
    let asterisk = 0;
    let required_attribute = 0;
    let aria_required = 0;

    let all_three = 0;
    let asterisk_required = 0;
    let asterisk_aria = 0;
    let required_with_aria = 0;
    for (const form_control of required_form_controls) {
      if (form_control.has_visible_required_asterisk) {
        asterisk++;
      }
      if (form_control.has_visible_required_asterisk && form_control.has_required) {
        asterisk_required++;
      }
      if (form_control.has_visible_required_asterisk && form_control.has_aria_required) {
        asterisk_aria++;
      }

      if (form_control.has_required) {
        required_attribute++;
      }
      if (form_control.has_required && form_control.has_aria_required) {
        required_with_aria++;
      }

      if (form_control.has_aria_required) {
        aria_required++;
      }


      if (form_control.has_visible_required_asterisk &&
          form_control.has_required &&
          form_control.has_aria_required) {
        all_three++;
      }
    }

    return {
      total,
      asterisk,
      required_attribute,
      aria_required,

      all_three,
      asterisk_required,
      asterisk_aria,
      required_with_aria,
    };
  } catch (e) {
    return {
      total: 0,
      asterisk: 0,
      required_attribute: 0,
      aria_required: 0,

      all_three: 0,
      asterisk_required: 0,
      asterisk_aria: 0,
      required_with_aria: 0,
    };
  }
''';

select
    client,
    count(0) as total_sites,
    countif(stats.total > 0) as total_sites_with_required_controls,
    sum(stats.total) as total_required_controls,

    sum(stats.asterisk) as total_asterisk,
    sum(stats.asterisk) / sum(stats.total) as perc_asterisk,

    sum(stats.required_attribute) as total_required_attribute,
    sum(stats.required_attribute) / sum(stats.total) as perc_required_attribute,

    sum(stats.aria_required) as total_aria_required,
    sum(stats.aria_required) / sum(stats.total) as perc_aria_required,

    sum(stats.all_three) as total_all_three,
    sum(stats.all_three) / sum(stats.total) as perc_all_three,

    sum(stats.asterisk_required) as total_asterisk_required,
    sum(stats.asterisk_required) / sum(stats.total) as perc_asterisk_required,

    sum(stats.asterisk_aria) as total_asterisk_aria,
    sum(stats.asterisk_aria) / sum(stats.total) as perc_asterisk_aria,

    sum(stats.required_with_aria) as total_required_with_aria,
    sum(stats.required_with_aria) / sum(stats.total) as perc_required_with_aria
from
    (
        select
            _table_suffix as client,
            requiredcontrols(json_extract_scalar(payload, '$._a11y')) as stats
        from `httparchive.pages.2021_07_01_*`
    )
group by client
