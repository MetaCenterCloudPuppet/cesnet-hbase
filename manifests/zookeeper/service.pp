# = Class hbase::zookeeper::config
#
# Starts and setups internal HBase zookeeper service (deprecated, always use external).
#
class hbase::zookeeper::service {
  service { $hbase::daemons['zookeeper']:
    ensure => running,
    enable => true,
  }
}
