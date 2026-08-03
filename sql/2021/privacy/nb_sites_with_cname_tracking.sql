with
    websites_using_cname_tracking as (
        select distinct
            net.reg_domain(domain) as domain,
            tracker,
            case
                when (tracker = 'sc.omtrdc.net' or tracker = '.2o7.net')
                then 'Adobe Experience Cloud'
                when tracker = 'pi.pardot.com'
                then 'Pardot'
                when tracker = 'hs.eloqua.com'
                then 'Oracle Eloqua'
                when tracker = '.wizaly.com'
                then 'Wizaly'
                when tracker = 'k.keyade.com'
                then 'Keyade'
                when tracker = 'partner.intentmedia.net'
                then 'Intent'
                when tracker = 'dnsdelegation.io'
                then 'Criteo'
                when
                    (
                        tracker
                        = 'afc4d9aa2a91d11e997c60ac8a4ec150-2082092489.eu-central-1.elb.amazonaws.com'
                        or tracker
                        = 'a88045584548111e997c60ac8a4ec150-1610510072.eu-central-1.elb.amazonaws.com'
                    )
                then 'Tracedock'
                when tracker = '.at-o.net'
                then 'AT Internet'
                when tracker = '.affex.org'
                then 'Ingenious Technologies'
                when (tracker = '.wt-eu02.net' or tracker = '.webtrekk.net')
                then 'Webtrekk'
                when tracker = '.actonsoftware.com'
                then 'Act-On Software'
                when tracker = '.eulerian.net'
                then 'Eulerian'
                else tracker
            end as company
        from
            `httparchive.almanac.cname_tracking`,
            unnest(split(substring(domains, 2, length(domains) - 2))) as domain
    ),

    totals as (
        select _table_suffix as _table_suffix, count(0) as total_pages
        from `httparchive.summary_pages.2021_07_01_*`
        group by _table_suffix
    )

select
    _table_suffix as client,
    company,
    count(distinct net.reg_domain(domain)) as nb_domains,
    count(0) as num_cname_pages,
    total_pages,
    count(0) / total_pages as pct_pages
from `httparchive.summary_pages.2021_07_01_*`
join totals using (_table_suffix)
join websites_using_cname_tracking on domain = net.reg_domain(urlshort)
group by client, company, total_pages
order by pct_pages desc, client
