# == Class hbase::install
#
class hbase::install {
  if $hbase::master_hostname == $::fqdn { contain hbase::master::install }
  if member($hbase::slaves, $::fqdn) { contain hbase::regionserver::install }
  if member($hbase::zookeeper_hostnames, $::fqdn) { contain hbase::zookeeper::install }
  if member($hbase::frontends, $::fqdn) { contain hbase::frontend::install }
}
