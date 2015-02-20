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
        thriftserver => 'hbase-thrift',
        restserver => 'hbase-rest',
        frontend => 'hbase',
      }
      $daemons = {
        master => 'hbase-master',
        regionserver => 'hbase-regionserver',
        thriftserver => 'hbase-thrift',
        restserver => 'hbase-rest',
      }
      $configdir_hadoop = '/etc/hadoop/conf'
      $confdir = '/etc/hbase/conf'
      $external_zookeeper = true
      $properties = {
        'hbase.tmp.dir' => '/var/lib/hbase',
      }
    }
    'RedHat': {
      $packages = {
        master => 'hbase',
        regionserver => 'hbase',
        thriftserver => 'hbase',
        restserver => 'hbase',
        zookeeper => 'hbase',
        frontend => 'hbase',
      }
      $daemons = {
        master => 'hbase-master',
        regionserver => 'hbase-regionserver',
        thriftserver => 'hbase-thrift',
        restserver => 'hbase-rest',
        zookeeper => 'hbase-zookeeper',
      }
      $configdir_hadoop = '/etc/hadoop'
      $confdir = '/etc/hbase'
      $external_zookeeper = false
      $properties = {
        'hbase.tmp.dir' => '/var/lib/hbase/cache',
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  $descriptions = {
    'hbase.tmp.dir' => 'The temporary directory.',
  }
  $perform = false

  $hbase_homedir = $::osfamily ? {
    'RedHat' => '/var/lib/hbase',
    'Debian' => '/var/lib/hbase',
  }

  $alternatives = $::osfamily ? {
    'RedHat' => undef,
    'Debian' => 'cluster',
  }

  $https_keystore = '/etc/security/server.keystore'
}
