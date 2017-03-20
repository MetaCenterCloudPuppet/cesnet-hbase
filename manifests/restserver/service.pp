# = Class hbase::restserver::service
#
# Starts and setpus HBase REST server service.
#
class hbase::restserver::service {
  service { $hbase::daemons['restserver']:
    ensure   => running,
    enable   => true,
    provider => "$hbase::service_provider",
  }
}
