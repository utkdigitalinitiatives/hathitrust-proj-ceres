## Notes and Things: HathiTrust and Project Ceres ##

### How to use this repository ###
This repository contains a set of XQuery scripts for querying, acquiring, and packaging Fedora book OBJs for HathiTrust. These scripts do ***not*** cover validation; HathiTrust provides a [validation utility](https://github.com/hathitrust/ht_sip_validator) that can be installed and used to verify the output.

#### Requirements ####
* Java (minimally ver. 8)
* [BaseX](https://basex.org) ([downloads available here](https://files.basex.org/releases/9.5.2/BaseX952.zip))

#### Installation ####
After downloading and extracting the BaseX zip archive, clone this repository into the `$basex/src/` directory.