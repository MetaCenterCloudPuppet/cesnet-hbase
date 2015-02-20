# == Class hbase::restserver
#
# HBase REST Server. Meant to be included to particular nodes. Declaration of the main hbase class with configuration is required.
#
class hbase::restserver {
  include 'hbase::restserver::install'
  include 'hbase::restserver::config'
  include 'hbase::restserver::service'

  Class['hbase::restserver::install'] ->
  Class['hbase::restserver::config'] ~>
  Class['hbase::restserver::service'] ->
  Class['hbase::restserver']
}
