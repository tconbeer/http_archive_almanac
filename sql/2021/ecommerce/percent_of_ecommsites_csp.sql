# standardSQL
# count the number of Content-Security-Policy and Content-Security-Policy-Report-Only
# headers across Ecommerce
create temporary function
hasheader(headers string, headername string)
returns bool deterministic
language js
as '''
  const parsed_headers = JSON.parse(headers);
  const matching_headers = parsed_headers.filter(h => h.name.toLowerCase() == headername.toLowerCase());
  return matching_headers.length > 0;
'''
;
select
    client,
    headername,
    count(distinct page) as total_hosts,
    count(distinct if(hasheader(headers, headername), page, null)) as num_with_header,
    count(distinct if(hasheader(headers, headername), page, null))
    / count(distinct page) as pct_with_header
from
    (
        select
            _table_suffix as client,
            page,
            json_extract(payload, '$.response.headers') as headers
        from `httparchive.requests.2021_07_01_*`
        join
            (
                select distinct _table_suffix, url
                from `httparchive.technologies.2021_07_01_*`
                where
                    category = 'Ecommerce'
                    and (
                        app != 'Cart Functionality'
                        and app != 'Google Analytics Enhanced eCommerce'
                    )
            )
            using
            (_table_suffix, url)
    ),
    unnest(
        ['Content-Security-Policy', 'Content-Security-Policy-Report-Only']
    ) as headername
group by client, headername
order by client, headername
