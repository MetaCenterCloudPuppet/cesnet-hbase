# = Class hbase::zookeeper::config
#
# Starts and setups internal HBase zookeeper service (deprecated, always use external).
#
class hbase::zookeeper::service {
  # using the provider to workaround the problem with service status detection
  # by Cloudera startup scripts
  if $hbase::service_provider {
    service { $hbase::daemons['zookeeper']:
      ensure   => running,
      enable   => true,
      provider => $hbase::service_provider,
    }
  } else {
    service { $hbase::daemons['zookeeper']:
      ensure => running,
      enable => true,
    }
  }
}
