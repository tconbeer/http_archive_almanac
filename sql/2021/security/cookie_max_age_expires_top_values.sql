# standardSQL
# Top 10 values of Max-Age and Expires cookie attributes.
create temporary function getcookieagevalues(headers string, epochofrequest numeric)
returns string deterministic
language js as '''
  const regexMaxAge = new RegExp(/max-age\\s*=\\s*(?<value>-*[0-9]+)/i);
  const regexExpires = new RegExp(/expires\\s*=\\s*(?<value>.*?)(;|$)/i);
  const parsed_headers = JSON.parse(headers);
  const cookies = parsed_headers.filter(h => h.name.match(/set-cookie/i));
  const cookieValues = cookies.map(h => h.value);
  const result = {
      "maxAge": [],
      "expires": []
  };
  cookieValues.forEach(cookie => {
      let maxAge = null;
      let expires = null;
      if (regexMaxAge.exec(cookie)) {
          maxAge = Number(regexMaxAge.exec(cookie)[1]);
          result["maxAge"].push(maxAge);
      }
      if (regexExpires.exec(cookie)) {
          expires = regexExpires.exec(cookie)[1];
          result["expires"].push(expires);
      }
  });
  return JSON.stringify(result);
'''
;

with
    max_age_values as (
        select client, max_age_value
        from
            `httparchive.almanac.requests`,
            unnest(
                json_query_array(
                    getcookieagevalues(response_headers, starteddatetime), '$.maxAge'
                )
            ) as max_age_value
        where date = '2021-07-01'
    ),

    expires_values as (
        select client, expires_value
        from
            `httparchive.almanac.requests`,
            unnest(
                json_query_array(
                    getcookieagevalues(response_headers, starteddatetime), '$.expires'
                )
            ) as expires_value
        where date = '2021-07-01'
    ),

    max_age as (
        select
            client,
            'max-age' as type,
            total_cookies_with_max_age as total,
            count(0) as freq,
            count(0) / total_cookies_with_max_age as pct,
            max_age_value as attribute_value
        from max_age_values
        join
            (
                select client, count(0) as total_cookies_with_max_age
                from max_age_values
                group by client
            )
            using(client)
        group by client, total, attribute_value
        order by freq desc
        limit 50
    ),

    expires as (
        select
            client,
            'expires' as type,
            total_cookies_with_expires as total,
            count(0) as freq,
            count(0) / total_cookies_with_expires as pct,
            expires_value as attribute_value
        from expires_values
        join
            (
                select client, count(0) as total_cookies_with_expires
                from expires_values
                group by client
            )
            using(client)
        group by client, total, attribute_value
        order by freq desc
        limit 50
    )

select *
from max_age
union all
select *
from expires
order by client, type, freq desc
