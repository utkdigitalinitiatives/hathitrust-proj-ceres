xquery version "3.1";

(:~
 : bridger
 : 2021-02-25
 :)

module namespace pids = "http://canofbees.org/xq/pids/";

(:~
 : queries the tuples endpoint of risearch for a list of book OBJs in a given collection
 : @url a Fedora repository URL
 : @user a Fedora user
 : @pass a Fedora password
 : @collection a valid Fedora collection PID
 :
 : @return an XML response in the sparql namespace
 :)
declare function pids:get-books(
  $url as xs:string?,
  $user as xs:string?,
  $pass as xs:string?,
  $collection as xs:string?
) as item()* {
  http:send-request(
    <http:request method="GET" username="{ $user }" password="{ $pass }" auth-method="Basic" send-authorization="true"/>,
    $url || "risearch?type=tuples&amp;flush=false&amp;lang=sparql&amp;format=sparql&amp;query=" ||
    ``[
      PREFIX fedora-model: <info:fedora/fedora-system:def/model#>
      PREFIX fedora-rels-ext: <info:fedora/fedora-system:def/relations-external#>
      SELECT ?pids
      FROM <#ri>
      WHERE {
        ?pids fedora-model:hasModel <info:fedora/islandora:bookCModel> ;
        fedora-rels-ext:isMemberOfCollection <info:fedora/`{ $collection }`> .
      }
    ]`` => normalize-space() => encode-for-uri()
  )
};

(:~
 : queries the tuples endpoint of Fedora's risearch for a list of page PIDs for a given book OBJ.
 : @url a Fedora repository URL
 : @user a Fedora user
 : @pass a Fedora password
 : @book a book OBJ PID
 :
 : @return an XML formatted list of page PIDs with page numbers.
 :)
declare function pids:get-pages(
  $url as xs:string?,
  $user as xs:string?,
  $pass as xs:string?,
  $book as xs:string?
) as item() {
  http:send-request(
    <http:request method="GET" username="{ $user }" password="{ $pass }"
      auth-method="Basic" send-authorization="true"/>,
    $url || "risearch?type=tuples&amp;flush=false&amp;lang=sparql&amp;format=sparql&amp;query=" ||
    ``[
      PREFIX fedora-model: <info:fedora/fedora-system:def/model#>
      PREFIX fedora-rels-ext: <info:fedora/fedora-system:def/relations-external#>
      PREFIX isl-rels-ext: <http://islandora.ca/ontology/relsext#>
      SELECT ?page ?numbers
      FROM <#ri>
      WHERE {
        ?page fedora-rels-ext:isMemberOf <info:fedora/`{ $book }`> ;
        isl-rels-ext:isPageNumber ?numbers .
      }
    ]`` => normalize-space() => encode-for-uri()
  )
};
