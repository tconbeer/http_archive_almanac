# standardSQL
# Prevalence of pages with /robots.txt and prevalence of pages with disallowed
# potentially sensitive endpoints (containing 'login', 'log-in', 'signin', 'sign-in',
# 'admin', 'auth', 'sso' or 'account').
create temporary function getalldisallowedendpoints(data string)
returns array < string > deterministic
language js
as '''
  const parsed_data = JSON.parse(data);
  if (parsed_data == null || parsed_data["/robots.txt"] == undefined || !parsed_data["/robots.txt"]["found"]) {
      return [];
  }
  const parsed_endpoints = parsed_data["/robots.txt"]["data"]["matched_disallows"];
  const endpoints_list = Object.keys(parsed_endpoints).map(key => parsed_endpoints[key]).flat();
  return Array.from(new Set(endpoints_list));
'''
;

select
    client,
    count(distinct page) as total_pages,
    count(
        distinct(case when has_robots_txt = 'true' then page end)
    ) as count_robots_txt,
    count(distinct(case when has_robots_txt = 'true' then page end))
    / count(distinct page) as pct_robots_txt,
    count(
        distinct(
            case when regexp_contains(disallowed_endpoint, r'.*/admin/.*') then page end
        )
    ) as count_disallow_admin,
    count(
        distinct(
            case when regexp_contains(disallowed_endpoint, r'.*/admin/.*') then page end
        )
    ) / count(distinct(case when has_robots_txt = 'true' then page end))
    as pct_disallow_admin,
    count(
        distinct(
            case
                when regexp_contains(disallowed_endpoint, r'.*/log-*in/.*') then page
            end
        )
    ) as count_disallow_login,
    count(
        distinct(
            case
                when regexp_contains(disallowed_endpoint, r'.*/log-*in/.*') then page
            end
        )
    ) / count(distinct(case when has_robots_txt = 'true' then page end))
    as pct_disallow_login,
    count(
        distinct(
            case
                when regexp_contains(disallowed_endpoint, r'.*/sign-*in/.*') then page
            end
        )
    ) as count_disallow_signin,
    count(
        distinct(
            case
                when regexp_contains(disallowed_endpoint, r'.*/sign-*in/.*') then page
            end
        )
    ) / count(distinct(case when has_robots_txt = 'true' then page end))
    as pct_disallow_signin,
    count(
        distinct(
            case when regexp_contains(disallowed_endpoint, r'.*/auth./*') then page end
        )
    ) as count_disallow_auth,
    count(
        distinct(
            case when regexp_contains(disallowed_endpoint, r'.*/auth/.*') then page end
        )
    ) / count(distinct(case when has_robots_txt = 'true' then page end))
    as pct_disallow_auth,
    count(
        distinct(
            case when regexp_contains(disallowed_endpoint, r'.*/sso/.*') then page end
        )
    ) as count_disallow_sso,
    count(
        distinct(
            case when regexp_contains(disallowed_endpoint, r'.*/sso/.*') then page end
        )
    ) / count(distinct(case when has_robots_txt = 'true' then page end))
    as pct_disallow_sso,
    count(
        distinct(
            case
                when regexp_contains(disallowed_endpoint, r'.*/account/.*') then page
            end
        )
    ) as count_disallow_account,
    count(
        distinct(
            case
                when regexp_contains(disallowed_endpoint, r'.*/account/.*') then page
            end
        )
    ) / count(distinct(case when has_robots_txt = 'true' then page end))
    as pct_disallow_account
from
    (
        select
            _table_suffix as client,
            url as page,
            json_value(
                json_value(payload, '$._well-known'), '$."/robots.txt".found'
            ) as has_robots_txt,
            getalldisallowedendpoints(
                json_value(payload, '$._well-known')
            ) as disallowed_endpoints
        from `httparchive.pages.2021_07_01_*`
    )
left join unnest(disallowed_endpoints) as disallowed_endpoint
group by client
