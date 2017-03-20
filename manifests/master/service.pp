# = Class hbase::master::config
#
# Starts and setups HBase master service.
#
class hbase::master::service {
  # using the provider to workaround the problem with service status detection
  # by Cloudera startup scripts
  if $hbase::service_provider {
    service { $hbase::daemons['master']:
      ensure   => running,
      enable   => true,
      provider => $hbase::service_provider,
    }
  } else {
    service { $hbase::daemons['master']:
      ensure => running,
      enable => true,
    }
  }
}
