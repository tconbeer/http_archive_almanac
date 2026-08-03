# standardSQL
# Usage of Credential Manager
select client, feature, num_urls as freq, total_urls as total, pct_urls as pct
from `httparchive.blink_features.usage`
where yyyymmdd = '20200801' and feature = 'CredentialManagerGet'
