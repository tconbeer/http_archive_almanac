# standardSQL
create temporary function pathresolve(path1 string, path2 string)
returns string
language js
as
    """
  if (!path2) return null;
  function normalizeStringPosix(e,t){for(var n="",r=-1,i=0,l=void 0,o=!1,h=0;h<=e.length;++h){if(h<e.length)l=e.charCodeAt(h);else{if(l===SLASH)break;l=SLASH}if(l===SLASH){if(r===h-1||1===i);else if(r!==h-1&&2===i){if(n.length<2||!o||n.charCodeAt(n.length-1)!==DOT||n.charCodeAt(n.length-2)!==DOT)if(n.length>2){for(var g=n.length-1,a=g;a>=0&&n.charCodeAt(a)!==SLASH;--a);if(a!==g){n=-1===a?"":n.slice(0,a),r=h,i=0,o=!1;continue}}else if(2===n.length||1===n.length){n="",r=h,i=0,o=!1;continue}t&&(n.length>0?n+="/..":n="..",o=!0)}else{var f=e.slice(r+1,h);n.length>0?n+="/"+f:n=f,o=!1}r=h,i=0}else l===DOT&&-1!==i?++i:i=-1}return n}function resolvePath(){for(var e=[],t=0;t<arguments.length;t++)e[t]=arguments[t];for(var n="",r=!1,i=void 0,l=e.length-1;l>=-1&&!r;l--){var o=void 0;l>=0?o=e[l]:(void 0===i&&(i=getCWD()),o=i),0!==o.length&&(n=o+"/"+n,r=o.charCodeAt(0)===SLASH)}return n=normalizeStringPosix(n,!r),r?"/"+n:n.length>0?n:"."}var SLASH=47,DOT=46,getCWD=function(){return""};if(/^https?:/.test(path2)){return path2;}if(/^\\//.test(path2)){return path1+path2.substr(1);}return resolvePath(path1, path2).replace(/^(https?:\\/)/, '$1/');
"""
;

select distinct
    date,
    client,
    regexp_replace(page, '^http:', 'https:') as pwa_url,
    pathresolve(
        regexp_replace(page, '^http:', 'https:'),
        regexp_extract(
            body, 'navigator\\.serviceWorker\\.register\\s*\\(\\s*["\']([^\\),\\s"\']+)'
        )
    ) as sw_url,
    pathresolve(
        regexp_replace(page, '^http:', 'https:'),
        regexp_extract(
            regexp_extract(body, '(<link[^>]+rel=["\']?manifest["\']?[^>]+>)'),
            'href=["\']?([^\\s"\'>]+)["\']?'
        )
    ) as manifest_url
from `httparchive.almanac.summary_response_bodies`
where
    date = '2020-08-01'
    and (
        (
            regexp_extract(
                body,
                'navigator\\.serviceWorker\\.register\\s*\\(\\s*["\']([^\\),\\s"\']+)'
            )
            is not null
            and regexp_extract(
                body,
                'navigator\\.serviceWorker\\.register\\s*\\(\\s*["\']([^\\),\\s"\']+)'
            )
            != '/'
        )
        or (
            regexp_extract(
                regexp_extract(body, '(<link[^>]+rel=["\']?manifest["\']?[^>]+>)'),
                'href=["\']?([^\\s"\'>]+)["\']?'
            )
            is not null
            and regexp_extract(
                regexp_extract(body, '(<link[^>]+rel=["\']?manifest["\']?[^>]+>)'),
                'href=["\']?([^\\s"\'>]+)["\']?'
            )
            != '/'
        )
    )
