# = Class hbase::regionserver::service
#
# Starts and setups HBase worker service.
#
class hbase::regionserver::service {
  service { $hbase::daemons['regionserver']:
    ensure => running,
    enable => true,
  }
}
