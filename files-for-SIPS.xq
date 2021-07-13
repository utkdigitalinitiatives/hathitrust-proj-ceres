xquery version "3.1";

import module namespace dsids = "http://canofbees.org/xq/dsids/"
  at "modules/get-dsids.xqm";
declare namespace result = "http://www.w3.org/2001/sw/DataAccess/rf1/result";

declare variable $path := file:current-dir();
declare variable $conf := doc($path || "config.xml")/conf;
declare variable $fedora-url external := $conf/fedora-url/text();
declare variable $write-path external := $conf/write-path/text();

for $record in csv:doc($path || "data/" || "PIDs-ARKs-SIPs.csv", map { "header": true() })//record
let $fs-pid := $record/book/text() => translate(':', '-')
let $fs-ark := $record/ark/text() => translate(':', '-') => translate('/', '-')
let $pages := doc($path || "data/" || $fs-pid || "-pages.xml")

return(
  for $result in $pages//result:result
  let $pid := $result/result:page/@uri/substring-after(data(), '/')
  let $pg-number := format-number($result/result:numbers/number(.), '00000000')
  return(
    $pid,
    if (file:exists($write-path || "data/" || $fs-pid)) then () else file:create-dir($write-path || "data/" || $fs-pid),
    (: fetch HOCR :)
    file:write(
        $write-path || "data/" || $fs-pid || "/" || string($pg-number) || ".xml",
        dsids:get-dsids($fedora-url, $pid, "HOCR"),
        map { "method": "xml" }
    ),
    (: fetch OCR :)
    file:write(
      $write-path || "data/" || $fs-pid || "/" || string($pg-number) || ".txt",
      dsids:get-dsids($fedora-url, $pid, "OCR"),
      map { "method": "text" }
    ),
    (: fetch OBJ :)
    file:write(
      $write-path || "data/" || $fs-pid || "/" || string($pg-number) || ".tif",
      dsids:get-dsids($fedora-url, $pid, "OBJ")
    )
  )
)
