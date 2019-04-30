# == Class hbase::regionserver
#
# HBase worker node. Meant to be included to particular nodes. Declaration of the main hbase class with configuration is required.
#
class hbase::regionserver {
  include ::hbase::regionserver::install
  include ::hbase::regionserver::config
  include ::hbase::regionserver::service

  Class['hbase::regionserver::install']
  -> Class['hbase::regionserver::config']
  ~> Class['hbase::regionserver::service']
  -> Class['hbase::regionserver']
}
