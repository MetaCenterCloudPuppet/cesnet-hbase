class hbase::thriftserver::install {
  include stdlib
  contain hbase::common::postinstall

  ensure_packages($hbase::packages['thriftserver'])
  Package[$hbase::packages['thriftserver']] -> Class['hbase::common::postinstall']
}
