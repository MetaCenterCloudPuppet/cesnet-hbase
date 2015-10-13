# == Class hbase::params
#
# This class is meant to be called from hbase
# It sets variables according to platform
#
class hbase::params {
  case "${::osfamily}-${::operatingsystem}" {
    /RedHat-Fedora/: {
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
      $properties = {
        'hbase.tmp.dir' => '/var/lib/hbase/cache',
      }
    }
    /Debian|RedHat/: {
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
      $properties = {
        'hbase.tmp.dir' => '/var/lib/hbase',
      }
    }
    default: {
      fail("${::operatingsystem} (${::osfamily}) not supported")
    }
  }

  $confdir = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => '/etc/hbase',
    /Debian|RedHat/ => '/etc/hbase/conf',
  }

  $configdir_hadoop = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => '/etc/hadoop',
    /Debian|RedHat/ => '/etc/hadoop/conf',
  }

  $descriptions = {
    'hbase.tmp.dir' => 'The temporary directory.',
  }

  $external_zookeeper = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => false,
    /Debian|RedHat/ => true,
  }

  $perform = false

  $hbase_homedir = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => '/var/lib/hbase',
    /Debian|RedHat/ => '/var/lib/hbase',
  }

  $https_keystore = '/etc/security/server.keystore'
}
