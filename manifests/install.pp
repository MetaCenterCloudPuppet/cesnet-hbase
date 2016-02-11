# == Class hbase::install
#
class hbase::install {
  include ::stdlib

  if $hbase::master_hostname == $::fqdn or member($hbase::backup_hostnames, $::fqdn) {
    contain hbase::master::install
  }
  if member($hbase::slaves, $::fqdn) { contain hbase::regionserver::install }
  if member($hbase::zookeeper_hostnames, $::fqdn) { contain hbase::zookeeper::install }
  if member($hbase::frontends, $::fqdn) { contain hbase::frontend::install }
}
