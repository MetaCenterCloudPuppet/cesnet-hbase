# == Class hbase::zookeeper
#
# HBase internal zookeeper (recommended external zookeeper instead). Meant to be included to particular nodes. Declaration of the main hbase class with configuration is required.
#
class hbase::zookeeper {
  include 'hbase::zookeeper::install'
  include 'hbase::zookeeper::config'
  include 'hbase::zookeeper::service'

  Class['hbase::zookeeper::install'] ->
  Class['hbase::zookeeper::config'] ~>
  Class['hbase::zookeeper::service'] ->
  Class['hbase::zookeeper']
}
