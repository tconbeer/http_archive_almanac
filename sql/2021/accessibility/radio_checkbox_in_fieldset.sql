# standardSQL
# How many radios and checkboxes are there. How many of those inputs are correctly
# placed in a fieldset with a legend?
create temporary function totalcheckboxandradio(payload string)
returns struct < radios int64,
checkboxes int64,
radios_in_fieldsets int64,
checkboxes_in_fieldsets int64,
checkboxes_in_fieldset_with_legend int64,
radios_in_fieldset_with_legend int64
> language js
as '''
  try {
    const a11y = JSON.parse(payload);

    let checkboxes_in_fieldset_with_legend = 0;
    let radios_in_fieldset_with_legend = 0;
    for (const fieldset of a11y.fieldset_radio_checkbox.fieldsets) {
      if (!fieldset.has_legend) {
        continue;
      }

      checkboxes_in_fieldset_with_legend += fieldset.total_checkbox;
      radios_in_fieldset_with_legend += fieldset.total_radio;
    }

    return {
      radios: a11y.fieldset_radio_checkbox.total_radio,
      checkboxes: a11y.fieldset_radio_checkbox.total_checkbox,
      radios_in_fieldsets: a11y.fieldset_radio_checkbox.total_radio_in_fieldsets,
      checkboxes_in_fieldsets: a11y.fieldset_radio_checkbox.total_checkbox_in_fieldsets,

      checkboxes_in_fieldset_with_legend,
      radios_in_fieldset_with_legend,
    };
  } catch (e) {
    return {
      radios: 0,
      checkboxes: 0,
      radios_in_fieldsets: 0,
      checkboxes_in_fieldsets: 0,

      checkboxes_in_fieldset_with_legend: 0,
      radios_in_fieldset_with_legend: 0,
    };
  }
'''
;

select
    client,
    count(0) as total_sites,
    countif(stats.checkboxes > 0 or stats.radios > 0) as total_applicable_sites,
    countif(stats.checkboxes > 0) as total_with_checkboxes,
    countif(stats.radios > 0) as total_with_radios,

    countif(
        (
            stats.checkboxes > 0 or stats.radios > 0
        ) and stats.checkboxes_in_fieldset_with_legend = 0
        and stats.radios_in_fieldset_with_legend = 0
    ) / countif(
        stats.checkboxes > 0 or stats.radios > 0
    ) as perc_sites_with_none_in_legend,
    countif(
        (
            stats.checkboxes > 0 or stats.radios > 0
        ) and stats.checkboxes_in_fieldset_with_legend = stats.checkboxes
        and stats.radios_in_fieldset_with_legend = stats.radios
    ) / countif(
        stats.checkboxes > 0 or stats.radios > 0
    ) as perc_sites_with_all_in_legend,

    sum(stats.checkboxes_in_fieldset_with_legend) / sum(
        stats.checkboxes
    ) as perc_checkboxes_in_legend,
    sum(stats.radios_in_fieldset_with_legend) / sum(
        stats.radios
    ) as perc_radios_in_legend
from
    (
        select
            _table_suffix as client,
            totalcheckboxandradio(json_extract_scalar(payload, '$._a11y')) as stats
        from `httparchive.pages.2021_07_01_*`
    )
group by client
