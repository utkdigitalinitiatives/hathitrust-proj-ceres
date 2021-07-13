xquery version "3.1";

(:~
 : 
 :)

declare namespace result = "http://www.w3.org/2001/sw/DataAccess/rf1/result";
declare namespace mods = "http://www.loc.gov/mods/v3";

declare variable $path := file:current-dir();
declare variable $conf := doc($path || "config.xml")/conf;
declare variable $fedora-url external := $conf/fedora-url/text();
declare variable $fedora-user external := $conf/fedora-user/text() => convert:string-to-base64() => string();
declare variable $fedora-pass external := $conf/fedora-pass/text() => convert:string-to-base64() => string();
declare variable $ezid-user external := $conf/ezid-user/text();
declare variable $ezid-pass external := $conf/ezid-pass/text();
declare variable $ezid-url external := $conf/ezid-url/text();

file:write-text-lines(
  $path || "data/PIDs-ARKs-SIPs.csv",
  ``["book","ark","sip"]``
),

for $book in file:list($path || "data/")[ends-with(., '-pages.xml')]
let $pid := $book => substring-before('-pages.xml') => translate('-', ':')
let $mods := fetch:xml($fedora-url || "/objects/" || $pid || "/datastreams/MODS/content")

let $request :=
  http:send-request(
    <http:request method="POST" username="{ $ezid-user }" password="{ $ezid-pass }"
      auth-method="Basic" send-authorization="true">
      <http:header name="Content-Type" value="text/plain"/>
      <http:body media-type="text/plain"/>
    </http:request>,
    $ezid-url,
    "erc.who: University of Tennessee (Knoxville campus). Agricultural Experiment Station" || out:nl() ||
    "erc.what: " || $mods/mods:mods/mods:titleInfo/mods:title/text() || out:nl() ||
    "erc.when: " || $mods/mods:mods/mods:originInfo/mods:dateIssued[@encoding="edtf"]/text() || out:nl() ||
    "_target: " || "https://digital.lib.utk.edu/collections/islandora/object/" || $pid
  )

return(
  prof:sleep(250),
  if ($request[1]//@status/data() = 201)
  then file:append-text-lines(
    $path || "data/" || "PIDs-ARKs-SIPs.csv",
    string-join(
      ($pid,
        $request[2] => substring-after('success: '),
        $request[2] => substring-after('success: ') => translate(":", "+") => translate("/", "=")
    ),
      ',')
    )
  else "There was a problem minting an EZID for " || $pid || ". Request response was " || $request[1]//@status/data() || ". Message was " || $request[1]//@message/data() || "."
)