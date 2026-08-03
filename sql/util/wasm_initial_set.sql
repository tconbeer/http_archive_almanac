select distinct url
from `httparchive.summary_requests.2021_09_01_*`
where ext = 'wasm' or mimetype = 'application/wasm'
