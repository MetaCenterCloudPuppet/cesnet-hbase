# == Class hbase::params
#
# This class is meant to be called from hbase
# It sets variables according to platform
#
class hbase::params {
  case $::osfamily {
    'Debian': {
      $packages = {
        master => 'hbase-master',
        regionserver => 'hbase-regionserver',
        frontend => 'hbase',
      }
      $daemons = {
        master => 'hbase-master',
        regionserver => 'hbase-regionserver',
      }
      $external_zookeeper = true
    }
    'RedHat': {
      $packages = {
        master => 'hbase',
        regionserver => 'hbase',
        zookeeper => 'hbase',
        frontend => 'hbase',
      }
      $daemons = {
        master => 'hbase-master',
        regionserver => 'hbase-regionserver',
        zookeeper => 'hbase-zookeeper',
      }
      $external_zookeeper = false
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  $perform = false
}
