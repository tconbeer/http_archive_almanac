# standardSQL
# 12_12b: Correct type used for email and phone inputs
create temporary function getinputinfo(payload string)
returns array < struct < detected_type string,
using_best_type boolean
>> language js as '''
  var new_line_regex = new RegExp('(?:\\r\\n|\\r|\\n)', 'g');
  function isFuzzyMatch(value, options) {
    value = value.replace(new_line_regex, '').trim().toLowerCase();
    for (let i = 0; i < options.length; i++) {
      if (value.indexOf(options[i]) >= 0) {
        return true;
      }
    }

    return false;
  }

  function nodeContainsTypeSignal(node, options) {
    if (node.id && isFuzzyMatch(node.id, options)) {
      return true;
    }
    if (node.name && isFuzzyMatch(node.name, options)) {
      return true;
    }
    if (node.placeholder && isFuzzyMatch(node.placeholder, options)) {
      return true;
    }
    if (node['aria-label'] && isFuzzyMatch(node['aria-label'], options)) {
      return true;
    }

    return false;
  }

  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    if (!almanac['input-elements']) {
      return [];
    }

    var email_input_signals = ['email', 'e-mail'];
    var tel_input_signals = ['phone', 'mobile', 'tel'];
    return almanac['input-elements']
      .map(function(node) {
        if (node.type !== 'text' && node.type !== 'email' && node.type !== 'tel') {
          return false;
        }

        if (nodeContainsTypeSignal(node, email_input_signals)) {
          return {
            detected_type: 'email',
            using_best_type: node.type === 'email'
          };
        }
        if (nodeContainsTypeSignal(node, tel_input_signals)) {
          return {
            detected_type: 'tel',
            using_best_type: node.type === 'tel'
          };
        }

        return false;
      })
      .filter(v => v !== false);
  } catch (e) {
    return [];
  }
'''
;

select
    input_info.detected_type as detected_type,
    input_info.using_best_type as using_best_type,
    sum(count(0)) over (partition by input_info.detected_type) as total_type_occurences,
    sum(count(distinct url)) over (
        partition by input_info.detected_type
    ) as total_sites_with_type,

    count(0) as total,
    count(distinct url) as total_sites,

    round(
        count(0) * 100 / sum(count(0)) over (partition by input_info.detected_type), 2
    ) as perc_inputs,
    round(
        count(distinct url)
        * 100
        / sum(count(distinct url)) over (partition by input_info.detected_type),
        2
    ) as perc_sites
from `httparchive.pages.2019_07_01_mobile`, unnest(getinputinfo(payload)) as input_info
group by input_info.detected_type, input_info.using_best_type
