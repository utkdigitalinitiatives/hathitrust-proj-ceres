## Notes and Things: HathiTrust and Project Ceres ##

### metadata ###
To keep things simple, DC. I think the following will work:

```
dc.title: $title
dc.date: $date
dc.publisher: University of Tennessee (Knoxville campus). Agricultural Service Extension
dc.type: Text
```

### pull back book PIDs ###

```sparql
PREFIX fedora-model: <info:fedora/fedora-system:def/model#>
PREFIX fedora-rels-ext: <info:fedora/fedora-system:def/relations-external#>
SELECT ?pids
FROM <#ri>
WHERE {
  ?pids fedora-model:hasModel <info:fedora/islandora:bookCModel> ;
    fedora-rels-ext:isMemberOfCollection <info:fedora/collections:agrtfhs> .
}
```