# = Class hbase::restserver::service
#
# Starts and setpus HBase REST server service.
#
class hbase::restserver::service {
  # using the provider to workaround the problem with service status detection
  # by Cloudera startup scripts
  if $hbase::service_provider {
    service { $hbase::daemons['restserver']:
      ensure   => running,
      enable   => true,
      provider => $hbase::service_provider,
    }
  } else {
    service { $hbase::daemons['restserver']:
      ensure => running,
      enable => true,
    }
  }
}
