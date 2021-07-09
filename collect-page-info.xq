xquery version "3.1";

import module namespace dsids = "http://canofbees.org/xq/dsids/"
  at "modules/get-dsids.xqm";
import module namespace pids = "http://canofbees.org/xq/pids/"
  at "modules/get-pids.xqm";

declare namespace result = "http://www.w3.org/2001/sw/DataAccess/rf1/result";
declare variable $path := file:current-dir();
declare variable $fedora-url external := "";
declare variable $fedora-user external := convert:string-to-base64("");
declare variable $fedora-pass external := convert:string-to-base64("");
declare variable $collection external := "";

(:
 : For a sequence of books in a collection, return a sequence of page info files
 : to the data directory.
 :)
for $full-pid in pids:get-books($fedora-url, $fedora-user, $fedora-user, $collection)//result:pids/@uri/data()
let $pid := $full-pid => substring-after('/')
return(
  (: return our page information for each book :)
  file:write(
    $path || "data/" || $pid => replace(':', '-') || "-pages.xml",
    pids:get-pages($fedora-url, $fedora-user, $fedora-pass, $pid),
    map { "method": "xml" }
  ),
  (: create a holding directory :)
  file:create-dir($path || "data/" || $pid)
  (::)
)