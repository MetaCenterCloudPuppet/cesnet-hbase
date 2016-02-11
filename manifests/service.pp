# == Class hbase::service
#
# This class is meant to be called from hbase.
#
# It ensures the services are running.
#
class hbase::service {
  include ::stdlib

  if $hbase::master_hostname == $::fqdn or member($hbase::backup_hostnames, $::fqdn) {
    contain hbase::master::service
  }

  if member($hbase::zookeeper_hostnames, $::fqdn) and !$hbase::external_zookeeper {
    contain hbase::zookeeper::service
  }

  if member($hbase::slaves, $::fqdn) { contain hbase::regionserver::service }
}
