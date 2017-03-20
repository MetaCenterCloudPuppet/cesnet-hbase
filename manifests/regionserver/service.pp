# = Class hbase::regionserver::service
#
# Starts and setups HBase worker service.
#
class hbase::regionserver::service {
  # using the provider to workaround the problem with service status detection
  # by Cloudera startup scripts
  if $hbase::service_provider {
    service { $hbase::daemons['regionserver']:
      ensure   => running,
      enable   => true,
      provider => $hbase::service_provider,
    }
  } else {
    service { $hbase::daemons['regionserver']:
      ensure => running,
      enable => true,
    }
  }
}
