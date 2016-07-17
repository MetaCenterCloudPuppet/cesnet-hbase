# = Class hbase::thriftserver::service
#
# Starts and setups HBase Thrift server service.
#
class hbase::thriftserver::service {
  service { $hbase::daemons['thriftserver']:
    ensure => running,
    enable => true,
  }
}
