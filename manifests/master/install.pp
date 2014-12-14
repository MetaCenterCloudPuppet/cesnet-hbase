class hbase::master::install {
  include stdlib
  contain hbase::common::postinstall

  ensure_packages($hbase::packages['master'])
  Package[$hbase::packages['master']] -> Class['hbase::common::postinstall']
}
