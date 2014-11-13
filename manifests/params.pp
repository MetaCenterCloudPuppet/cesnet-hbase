# == Class hbase::params
#
# This class is meant to be called from hbase
# It sets variables according to platform
#
class hbase::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'hbase'
      $service_name = 'hbase'
    }
    'RedHat': {
      $package_name = 'hbase'
      $service_name = 'hbase'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  $hdfs_hostname = 'localhost'
}
