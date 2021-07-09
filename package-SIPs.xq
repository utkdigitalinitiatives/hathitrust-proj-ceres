xquery version "3.1";

declare variable $path := file:current-dir();

declare function local:md5-file(
  $path as xs:string?
) as xs:string {
  $path => file:read-binary() => hash:md5() => xs:hexBinary() => string() => lower-case()
};

declare function local:sip-metadata(
  $path as xs:string?
) as item()* {
  file:append-text-lines(
  $path || "/" || "meta.yml",
    (
      "capture_date: " || "",
      "scanner_user: University of Tennessee, Knoxville. Libraries: Digital Production Lab",
      out:nl(),
      "contone_resolution_dpi: " || "",
      "scanning_order: left-to-right",
      "reading_order: left-to-right",
      out:nl(),
      "pagedata:",
      (
        for $tif in file:list($path, false(), '*.tif')
        order by $tif ascending
        count $count
        return(
          "  " || $tif || ": { orderlabel: " || '"' || $count || '" }'
        )
      )
    )
  ),
  let $checksums :=
    (
      for $file in file:descendants($path)
      return(
        local:md5-file($file) || " " || file:name($file)
      )
    )
  return file:append-text-lines(
    $path || "/" || "checksum.md5",
    $checksums
  )
};

for $entry in csv:doc($path || "data/PIDs-ARKs-SIPs.csv", map {"header": true()})//record
let $dir-name := $entry/book/text() => translate(':', '-')
let $sip-name := $entry/sip/text()
let $dir := $path || "data/" || $dir-name
return(
  "sip-metadata: ",
  local:sip-metadata($dir),
  "files flowr: ",
  let $files := file:list($dir)
  return(
    $dir,
    $files
  ) 
(:  let $zip :=
    archive:create(
      $files,
      for $file in $files
      return file:read-binary($dir || "/" || $file)
    )
  return
    file:write-binary(
      $path || "/data/" || $sip-name || ".zip",
      $zip
    ):)
)