# standardSQL
# Robots txt user agent usage BY rank
# returns all the data we need from _robots_txt
create temporary function getrobotstxtuseragents(robots_txt_string string)
returns struct<user_agents array<string>>
language js
as
    '''
var result = {
  user_agents: []
};
try {
    var robots_txt = JSON.parse(robots_txt_string);
    if (Array.isArray(robots_txt) || typeof robots_txt != 'object') return result;
    if (robots_txt.user_agents) {
      var uas = robots_txt.user_agents.map(ua => ua.toLowerCase());
      var uas =  uas.filter(function(item, pos) { return uas.indexOf(item) == pos;}); // remove duplicates
      result.user_agents = uas;
    }
} catch (e) {}
return result;
'''
;

with
    totals as (
        select _table_suffix as client, rank_grouping, count(0) as rank_page_count
        from
            `httparchive.summary_pages.2021_07_01_*`,
            unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where rank <= rank_grouping
        group by client, rank_grouping
    ),

    robots as (
        select
            _table_suffix,
            url,
            getrobotstxtuseragents(
                json_extract_scalar(payload, '$._robots_txt')
            ) as robots_txt_user_agent_info
        from `httparchive.pages.2021_07_01_*`
    ),

    base as (
        select distinct _table_suffix as client, user_agent, rank, url as page
        from robots, unnest(robots_txt_user_agent_info.user_agents) as user_agent
        join `httparchive.summary_pages.2021_07_01_*` using (_table_suffix, url)
    )

select
    client,
    user_agent,
    rank_grouping,
    case
        when rank_grouping = 10000000 then 'all' else format("%'d", rank_grouping)
    end as ranking,
    rank_page_count,
    count(distinct page) as pages,
    safe_divide(count(distinct page), rank_page_count) as pct
from base, unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
join totals using (client, rank_grouping)
where rank <= rank_grouping
group by client, user_agent, rank_grouping, rank_page_count
having pages > 500
order by rank_grouping, pct desc
