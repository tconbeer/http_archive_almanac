select  -- noqa: disable=L044
    date,
    client,
    page,
    url,
    body,
    truncated,
    null as pageid,
    requestid as requestid,
    starteddatetime,
    time,
    method,
    urlshort,
    redirecturl,
    firstreq,
    firsthtml,
    reqhttpversion,
    reqheaderssize,
    reqbodysize,
    reqcookielen,
    reqotherheaders,
    status,
    resphttpversion,
    respheaderssize,
    respbodysize,
    respsize,
    respcookielen,
    expage as expage,
    * except (
        date,
        client,
        page,
        url,
        body,
        truncated,
        requestid,
        starteddatetime,
        time,
        method,
        urlshort,
        redirecturl,
        firstreq,
        firsthtml,
        reqhttpversion,
        reqheaderssize,
        reqbodysize,
        reqcookielen,
        reqotherheaders,
        status,
        resphttpversion,
        respheaderssize,
        respbodysize,
        respsize,
        respcookielen,
        expage,
        type,
        ext,
        format,
        payload
    ),
    null as crawlid,
    type,
    ext,
    format,
    payload
from (select * from `httparchive.almanac.requests` where date = '2020-08-01')
join
    (select _table_suffix as client, * from `httparchive.response_bodies.2020_08_01_*`)
    using
    (client, page, url, requestid)
