xquery version "3.1";

(:~
 : bridger
 : 2021-02-25
 :)

module namespace dsids = "http://canofbees.org/xq/dsids/";

declare function dsids:grab-metadata(
  $url as xs:string?,
  $metadata-dsid as xs:string?,
  $pid as xs:string?
) as document-node() {
  http:send-request(
    <http:request method="GET"/>,
    $url || "/objects/" || $pid || "/datastreams/" || $metadata-dsid || "/content"
  )
};

declare function dsids:grab-dsids(
  $url as xs:string?,
  $dsid as xs:string?,
  $pid as xs:string?
) as item() {
  http:send-request(
    <http:request method="GET"/>,
    $url || "/objects/" || $pid || "/datastreams/" || $dsid || "/content"
  )
};

