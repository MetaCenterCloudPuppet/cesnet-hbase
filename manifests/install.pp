# == Class hbase::install
#
class hbase::install {
  include stdlib

  if ($hbase::daemons or $hbase::frontend) {
    ensure_packages($hbase::package_name)
  }
}
