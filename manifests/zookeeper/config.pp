class hbase::zookeeper::config {
  contain hbase::common::config
  contain hbase::common::daemons::config
}
