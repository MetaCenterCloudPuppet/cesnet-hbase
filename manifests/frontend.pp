# == Class hbase::frontend
#
# HBase client. Meant to be included to particular nodes. Declaration of the main hbase class with configuration is required.
#
class hbase::frontend {
  include 'hbase::frontend::install'
  include 'hbase::frontend::config'

  Class['hbase::frontend::install'] ->
  Class['hbase::frontend::config'] ->
  Class['hbase::frontend']
}
