class hbase::frontend::install {
  include stdlib
  contain hbase::common::postinstall

  ensure_packages($hbase::packages['frontend'])
  Package[$hbase::packages['frontend']] -> Class['hbase::common::postinstall']
}
