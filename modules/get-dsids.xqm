xquery version "3.1";

(:~
 : bridger
 : 2021-02-25
 :)

module namespace dsids = "http://canofbees.org/xq/dsids/";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace ifd0 = "http://ns.exiftool.org/EXIF/IFD0/1.0/";
declare namespace xmp-xmp = "http://ns.exiftool.org/XMP/XMP-xmp/1.0";

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

(:~
 : For a given DSID, returns an item to be serialized to disk.
 : @param $url a Fedora repository URL
 : @param $pid a Fedora PID
 : @param $dsid a Fedora datastream id
 :
 : @return an item
 :)
declare function dsids:get-dsids(
  $url as xs:string?,
  $pid as xs:string?,
  $dsid as xs:string?
) as item()* {
  switch($dsid)
    case "DC" return fetch:xml($url || "/objects/" || $pid || "/datastreams/DC/content", map { "intparse": "true"})
    case "HOCR" return fetch:xml($url || "/objects/" || $pid || "/datastreams/HOCR/content", map { "intparse": "true" })
    case "MODS" return fetch:xml($url || "/objects/" || $pid || "/datastreams/MODS/content", map { "intparse": "true" })
    case "OBJ" return fetch:binary($url || "/objects/" || $pid || "/datastreams/OBJ/content")
    case "OCR" return fetch:text($url || "/objects/" || $pid || "/datastreams/OCR/content", "UTF-8", true())
    default return "No matching DSID"
};

declare function dsids:exif(
  $path as xs:string?
) as item()* {
  try {
    proc:system('exiftool', ("-X", $path)) => parse-xml()
  } catch proc:error {
    "exiftool is not available. " || $err:description
  }
};

declare function dsids:get-create-date(
  $path as xs:string
) as xs:string {
  dsids:exif($path)//*:CreateDate/text() => substring-before(' ') => translate(':', '-')
};