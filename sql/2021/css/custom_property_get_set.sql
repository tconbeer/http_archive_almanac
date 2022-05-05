# standardSQL
create temporary function getcustompropertyusage(payload string)
returns array < struct < name string,
freq int64 >> language js
options(library = "gs://httparchive/lib/css-utils.js")
as '''
try {
  function compute(vars) {
    let ret = {
      get_only: 0,
      set_only: 0,
      get_set: 0
    };

    for (let property in vars.summary) {
      let rw = vars.summary[property];

      if (rw.get.length > 0) {
        if (rw.set.length > 0) {
          ret.get_set++;
        }
        else {
          ret.get_only++;
        }
      }
      else {
        ret.set_only++;
      }
    }

    return ret;
  }
  var $ = JSON.parse(payload);
  var vars = JSON.parse($['_css-variables']);
  var custom_properties = compute(vars);
  return Object.entries(custom_properties).map(([name, freq]) => ({name, freq}))
} catch (e) {
  return null;
}
'''
;

select
    client,
    name as usage,
    sum(freq) as freq,
    sum(sum(freq)) over (partition by client) as total,
    sum(freq) / sum(sum(freq)) over (partition by client) as pct
from
    (
        select _table_suffix as client, usage.name, usage.freq
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(getcustompropertyusage(payload)) as usage
    )
group by client, usage
order by pct desc
