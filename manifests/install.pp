# == Class hbase::install
#
class hbase::install {
  include stdlib

  ensure_packages($hbase::package_name)
}
