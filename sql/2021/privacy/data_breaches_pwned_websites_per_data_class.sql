# standardSQL
# HaveIBeenPwned breaches by type of data breached, e.g., email addresses
# https://docs.google.com/spreadsheets/d/148SxZICZ24O44roIuEkRgbpIobWXpqLxegCDhIiX8XA/edit#gid=1158689200
select
    data_class,
    count(distinct title) as number_of_breaches,
    sum(pwncount) as number_of_affected_accounts
from `httparchive.almanac.breaches`, unnest(json_value_array(dataclasses)) as data_class
where date = '2021-07-01' and breachdate between '2020-08-01' and '2021-07-31'
group by data_class
order by number_of_breaches desc
