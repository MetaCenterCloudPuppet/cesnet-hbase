# = Class hbase::master::config
#
# Starts and setups HBase master service.
#
class hbase::master::service {
  service { $hbase::daemons['master']:
    ensure   => running,
    enable   => true,
    provider => "$hbase::service_provider",
  }
}
