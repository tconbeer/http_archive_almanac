# standardSQL
# Pages that participate in the FLoC origin trial
create temp function retrieveorigintrials(tokenelem string)
returns struct < validityelem string,
versionelem integer,
originelem string,
subdomainelem boolean,
thirdpartyelem boolean,
usageelem string,
featureelem string,
expiryelem timestamp > language js
-- https://stackoverflow.com/questions/60094731/can-i-use-textencoder-in-bigquery-js-udf
options(library = "gs://fh-bigquery/js/inexorabletash.encoding.js")
-- https://github.com/GoogleChrome/OriginTrials/blob/gh-pages/check-token.html
as """
  let validityElem,
    versionElem,
    originElem,
    subdomainElem,
    thirdpartyElem,
    usageElem,
    featureElem,
    expiryElem,
    origin_trial_metadata = {};

  const utf8Decoder = new TextDecoder('utf-8', {fatal: true});

  // atob: https://stackoverflow.com/a/44836424/7391782

  var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';

  function InvalidCharacterError(message) {
    this.message = message;
  }
  InvalidCharacterError.prototype = new Error;
  InvalidCharacterError.prototype.name = 'InvalidCharacterError';

  // encoder
  // [https://gist.github.com/1020396] by [https://github.com/atk]
  const atob = function (input) {
    var str = String(input).replace(/[=]+$/, ''); // #31: ExtendScript bad parse of /=
    if (str.length % 4 == 1) {
      throw new InvalidCharacterError("'atob' failed: The string to be decoded is not correctly encoded.");
    }
    for (
      // initialize result and counters
      var bc = 0, bs, buffer, idx = 0, output = '';
      // get next character
      buffer = str.charAt(idx++);
      // character found in table? initialize bit storage and add its ascii value;
      ~buffer && (bs = bc % 4 ? bs * 64 + buffer : buffer,
        // and if not first of each 4 characters,
        // convert the first 8 bits to one ascii character
        bc++ % 4) ? output += String.fromCharCode(255 & bs >> (-2 * bc & 6)) : 0
    ) {
      // try to find character in table (0-63, not found => -1)
      buffer = chars.indexOf(buffer);
    }
    return output;
  };

  // Base64-decode the token into a Uint8Array.
  let tokenStr;
  try {
    tokenStr = atob(tokenElem);
  } catch (e) {
    console.error(e);
    origin_trial_metadata.validityElem = 'Invalid Base64';
  return origin_trial_metadata;
  }
  const token = new Uint8Array(tokenStr.length);
  for (let i = 0; i < token.length; i++) {
    token[i] = tokenStr.charCodeAt(i);
  }

  // Check that the version number is 2 or 3.
  const version = token[0];
  versionElem = '' + version;
  if (version !== 2 && version !== 3) {
    origin_trial_metadata.validityElem = 'Unknown version';
  return origin_trial_metadata;
  }

  // Pull the fields out of the token.
  if (token.length < 69) {
    origin_trial_metadata.validityElem = 'Token is too short';
  return origin_trial_metadata;
  }
  const payloadLength = new DataView(token.buffer, 65, 4).getInt32(0, /*littleEndian=*/ false);
  const payload = new Uint8Array(token.buffer, 69);
  if (payload.length !== payloadLength) {
    origin_trial_metadata.validityElem = 'Token is ' + payload.length + ' bytes; expected ' + payloadLength;
  return origin_trial_metadata;
  }

  // The version + length + payload is signed.
  const signedData = new Uint8Array(token.buffer.slice(64));
  signedData[0] = token[0];

  // Pull the fields out of the JSON payload.
  let json;
  try {
    json = utf8Decoder.decode(payload);
  } catch (e) {
    origin_trial_metadata.validityElem = 'Invalid UTF-8';
  return origin_trial_metadata;
  }

  let obj;
  try {
    obj = JSON.parse(json);
  } catch (e) {
    origin_trial_metadata.validityElem = 'Invalid JSON';
  return origin_trial_metadata;
  }

  originElem = obj.origin;
  subdomainElem = !!obj.isSubdomain;
  thirdpartyElem = !!obj.isThirdParty;
  usageElem = obj.usage;
  featureElem = obj.feature;
  let expiry;
  try {
    expiry = parseInt(obj.expiry);
  } catch (e) {
    origin_trial_metadata.validityElem = "Expiry value wasn't an integer";
    origin_trial_metadata.expiryElem = obj.expiry;
  return origin_trial_metadata;
  }

  origin_trial_metadata = {
    validityElem: 'Valid',
    versionElem: versionElem,
    originElem: originElem,
    subdomainElem: subdomainElem,
    thirdpartyElem: thirdpartyElem,
    usageElem: usageElem,
    featureElem: featureElem,
    expiryElem: expiryElem,
  };

  return origin_trial_metadata;
"""
;

with
    pages_origin_trials as (
        select
            _table_suffix as client,
            url,
            json_value(payload, '$._origin-trials') as metrics
        from `httparchive.pages.2021_07_01_*`
    ),

    response_headers as (
        select
            client,
            page,
            lower(json_value(response_header, '$.name')) as header_name,
            -- may not lowercase this value as it is a base64 string
            json_value(response_header, '$.value') as header_value
        from
            `httparchive.almanac.requests`,
            unnest(json_query_array(response_headers)) response_header
        where date = '2021-07-01' and firsthtml = true
    ),

    meta_tags as (
        select
            client,
            url as page,
            lower(json_value(meta_node, '$.http-equiv')) as tag_name,
            -- may not lowercase this value as it is a base64 string
            json_value(meta_node, '$.content') as tag_value
        from
            (
                select
                    _table_suffix as client,
                    url,
                    json_value(payload, '$._almanac') as metrics
                from `httparchive.pages.2021_07_01_*`
            ),
            unnest(json_query_array(metrics, '$.meta-nodes.nodes')) meta_node
        where json_value(meta_node, '$.http-equiv') is not null
    ),

    extracted_origin_trials_from_custom_metric as (
        select
            client,
            url as site,  -- the home page that was crawled
            retrieveorigintrials(
                json_value(metric, '$.token')
            ) as origin_trials_from_custom_metric
        from pages_origin_trials, unnest(json_query_array(metrics)) metric
    ),

    extracted_origin_trials_from_headers_and_meta_tags as (
        select
            client,
            page as site,  -- the home page that was crawled
            retrieveorigintrials(
                if(header_name = 'origin-trial', header_value, tag_value)
            ) as origin_trials_from_headers_and_meta_tags
        from response_headers
        full outer join meta_tags using(client, page)
        where header_name = 'origin-trial' or tag_name = 'origin-trial'
    )


select
    client,
    coalesce(
        origin_trials_from_custom_metric.featureelem,
        origin_trials_from_headers_and_meta_tags.featureelem
    ) as featureelem,
    -- crawled sites containing at leat one origin trial
    count(distinct site) as number_of_websites,
    count(
        distinct coalesce(
            origin_trials_from_custom_metric.originelem,
            origin_trials_from_headers_and_meta_tags.originelem
        )
    ) as number_of_origins  -- origins with an origin trial
from extracted_origin_trials_from_custom_metric
full outer join extracted_origin_trials_from_headers_and_meta_tags using(client, site)
where
    (
        origin_trials_from_custom_metric.featureelem = 'InterestCohortAPI'
        or origin_trials_from_custom_metric.featureelem = 'ConversionMeasurement'
        or origin_trials_from_custom_metric.featureelem = 'TrustTokens'
        or origin_trials_from_headers_and_meta_tags.featureelem = 'InterestCohortAPI'
        or
        origin_trials_from_headers_and_meta_tags.featureelem
        = 'ConversionMeasurement'
        or origin_trials_from_headers_and_meta_tags.featureelem = 'TrustTokens'
    )
group by client, featureelem
order by client, featureelem
