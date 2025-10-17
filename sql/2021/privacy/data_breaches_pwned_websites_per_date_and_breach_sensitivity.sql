# standardSQL
# 'Sensitive' HaveIBeenPwned breaches, where the existence of an account is sensitive
# in and of itself.
# https://haveibeenpwned.com/FAQs#SensitiveBreach
# https://docs.google.com/spreadsheets/d/148SxZICZ24O44roIuEkRgbpIobWXpqLxegCDhIiX8XA/edit#gid=1435927653
select
    date_trunc(date(breachdate), month) as breach_date,
    if(issensitive, 'Sensitive', 'Not sensitive') as sensitivity,
    count(distinct title) as number_of_breaches,
    sum(pwncount) as number_of_affected_accounts
from `httparchive.almanac.breaches`
where date = '2021-07-01' and breachdate between '2020-08-01' and '2021-07-31'
group by breach_date, sensitivity
order by breach_date, sensitivity
