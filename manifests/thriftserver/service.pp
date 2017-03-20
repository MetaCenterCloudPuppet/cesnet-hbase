# = Class hbase::thriftserver::service
#
# Starts and setups HBase Thrift server service.
#
class hbase::thriftserver::service {
  # using the provider to workaround the problem with service status detection
  # by Cloudera startup scripts
  if $hbase::service_provider {
    service { $hbase::daemons['thriftserver']:
      ensure   => running,
      enable   => true,
      provider => $hbase::service_provider,
    }
  } else {
    service { $hbase::daemons['thriftserver']:
      ensure => running,
      enable => true,
    }
  }
}
