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

declare function dsids:get-dsids(
  $url as xs:string?,
  $pid as xs:string?,
  $dsid as xs:string?
) as item()* {
  switch($dsid)
    case "DC" return fetch:xml($url || "objects/" || $pid || "/datastreams/DC/content", map { "intparse": "true"})
    case "HOCR" return fetch:xml($url || "objects/" || $pid || "/datastreams/HOCR/content", map { "intparse": "true" })
    case "MODS" return fetch:xml($url || "objects/" || $pid || "/datastreams/MODS/content", map { "intparse": "true" })
    case "OBJ" return fetch:binary($url || "objects/" || $pid || "/datastreams/OBJ/content")
    case "OCR" return fetch:text($url || "objects/" || $pid || "/datastreams/OCR/content", "UTF-8", true())
    default return "No matching DSID"
};

