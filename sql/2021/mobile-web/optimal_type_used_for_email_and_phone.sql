# standardSQL
# Optimal type used for email and phone inputs
create temporary function getinputinfo(payload string)
returns array<struct<detected_type string, using_best_type boolean>>
language js
as '''
  const new_line_regex = new RegExp('(?:\\r\\n|\\r|\\n)', 'g');
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
    const almanac = JSON.parse(payload);
    if (!almanac.input_elements) {
      return [];
    }

    const email_input_signals = ['email', 'e-mail'];
    const tel_input_signals = ['phone', 'mobile', 'tel'];
    return almanac.input_elements.nodes
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
    # is the input field using the best "type" attribute? E.g., type=email for an email
    input_info.using_best_type as using_best_type_attr,

    # How many times an input requesting this type of data (email or phone) occurs
    total_type_occurences,
    # How many sites have an input requesting this type of data (email or phone)
    total_pages_with_type,

    count(0) as total,
    count(distinct url) as total_pages,

    count(0) / total_type_occurences as pct_inputs,
    count(distinct url) / total_pages_with_type as pct_pages
from
    `httparchive.pages.2021_07_01_mobile`,
    unnest(getinputinfo(json_extract_scalar(payload, '$._almanac'))) as input_info
left join
    (
        select
            input_info.detected_type as detected_type,
            # How many times an input requesting this type of data (email or phone)
            # occurs
            count(0) as total_type_occurences,
            # How many sites have an input requesting this type of data (email or phone)
            count(distinct url) as total_pages_with_type
        from
            `httparchive.pages.2021_07_01_mobile`,
            unnest(
                getinputinfo(json_extract_scalar(payload, '$._almanac'))
            ) as input_info
        group by input_info.detected_type
    ) using (detected_type)
group by
    input_info.detected_type,
    input_info.using_best_type,
    total_type_occurences,
    total_pages_with_type
