# = Class hbase::zookeeper::config
#
# Configuration for internal HBase zookeeper (deprecated, always use external).
#
class hbase::zookeeper::config {
  contain hbase::common::config
  contain hbase::common::daemons::config
}
