# == Class hbase::master
#
# HBase Master. Meant to be included to particular nodes. Declaration of the main hbase class with configuration is required.
#
class hbase::master {
  include ::hbase::master::install
  include ::hbase::master::config
  include ::hbase::master::service

  Class['hbase::master::install']
  -> Class['hbase::master::config']
  ~> Class['hbase::master::service']
  -> Class['hbase::master']
}
