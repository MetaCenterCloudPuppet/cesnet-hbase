class hbase::restserver::install {
  include stdlib
  contain hbase::common::postinstall

  ensure_packages($hbase::packages['restserver'])
  Package[$hbase::packages['restserver']] -> Class['hbase::common::postinstall']
}
