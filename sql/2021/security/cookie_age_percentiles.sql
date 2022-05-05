# standardSQL
# Percentiles of Max-Age-attribute, Expires-attribute and real age (Max-Age has
# precedence) of cookies set over all requests
create temporary function getcookieagevalues(headers string, epochofrequest numeric)
returns string deterministic
language js
as '''
  const regexMaxAge = new RegExp(/max-age\\s*=\\s*(?<value>-*[0-9]+)/i);
  const regexExpires = new RegExp(/expires\\s*=\\s*(?<value>.*?)(;|$)/i);
  const parsed_headers = JSON.parse(headers);
  const cookies = parsed_headers.filter(h => h.name.match(/set-cookie/i));
  const cookieValues = cookies.map(h => h.value);
  const result = {
      "maxAge": [],
      "expires": [],
      "realAge": []
  };
  cookieValues.forEach(cookie => {
      let maxAge = null;
      let expires = null;
      if (regexMaxAge.exec(cookie)) {
          maxAge = Number(regexMaxAge.exec(cookie)[1]);
          result["maxAge"].push(maxAge);
      }
      if (regexExpires.exec(cookie)) {
          expires = Math.round(Number(new Date(regexExpires.exec(cookie)[1])) / 1000) - epochOfRequest;
          result["expires"].push(Number.isSafeInteger(expires) ? expires : null);
      }
      if (maxAge) {
          result["realAge"].push(maxAge);
      } else if (expires) {
          result["realAge"].push(expires);
      }
  });
  return JSON.stringify(result);
'''
;

with
    age_values as (
        select client, getcookieagevalues(response_headers, starteddatetime) as values
        from `httparchive.almanac.requests`
        where date = '2021-07-01'
    ),

    max_age_values as (
        select
            client,
            percentile,
            approx_quantiles(safe_cast(max_age_value as numeric), 1000 ignore nulls) [
                offset (percentile * 10)
            ] as max_age
        from
            age_values,
            unnest(json_query_array(values, '$.maxAge')) as max_age_value,
            unnest( [10, 25, 50, 75, 90, 100]) as percentile
        group by percentile, client
        order by percentile, client
    ),

    expires_values as (
        select
            client,
            percentile,
            approx_quantiles(safe_cast(expires_value as numeric), 1000 ignore nulls) [
                offset (percentile * 10)
            ] as expires
        from
            age_values,
            unnest(json_query_array(values, '$.expires')) as expires_value,
            unnest( [10, 25, 50, 75, 90, 100]) as percentile
        group by percentile, client
        order by percentile, client
    ),

    real_age_values as (
        select
            client,
            percentile,
            approx_quantiles(safe_cast(real_age_value as numeric), 1000 ignore nulls) [
                offset (percentile * 10)
            ] as real_age
        from
            age_values,
            unnest(json_query_array(values, '$.realAge')) as real_age_value,
            unnest( [10, 25, 50, 75, 90, 100]) as percentile
        group by percentile, client
        order by percentile, client
    )

select client, percentile, max_age, expires, real_age
from max_age_values
join expires_values using(client, percentile)
join real_age_values using(client, percentile)
order by client, percentile
