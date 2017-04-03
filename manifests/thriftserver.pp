# == Class hbase::thriftserver
#
# HBase Thrift Server. Meant to be included to particular nodes. Declaration of the main hbase class with configuration is required.
#
class hbase::thriftserver {
  include 'hbase::thriftserver::install'
  include 'hbase::thriftserver::config'
  include 'hbase::thriftserver::service'

  Class['hbase::thriftserver::install']
  -> Class['hbase::thriftserver::config']
  ~> Class['hbase::thriftserver::service']
  -> Class['hbase::thriftserver']
}
