class hbase::frontend::config {
  contain hbase::common::config
  if $hbase::external_zookeeper {
    contain hbase::common::keytab
  }
}
