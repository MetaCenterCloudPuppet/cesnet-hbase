# == Class hbase::config
#
# This class is called from hbase.
#
class hbase::config {
  include ::stdlib
  contain hbase::common::config

  if $hbase::master_hostname == $::fqdn or member($hbase::backup_hostnames, $::fqdn) {
    contain hbase::master::config
  }
  if member($hbase::slaves, $::fqdn) { contain hbase::regionserver::config }
  if member($hbase::zookeeper_hostnames, $::fqdn) { contain hbase::zookeeper::config }
  if member($hbase::frontends, $::fqdn) { contain hbase::frontend::config }

  # setup on HDFS (directory layout)
  if $hbase::hdfs_hostname == $::fqdn {
    contain hbase::hdfs
  }
}
