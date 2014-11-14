# == Class hbase::service
#
# This class is meant to be called from hbase
# It ensure the service is running
#
class hbase::service {
  include stdlib

  if $hbase::master_hostname == $::fqdn {
    service { 'hbase-master':
      ensure => running,
      enable => true,
    }
  }

  if $hbase::zookeeper_hostname == $::fqdn and !$hbase::external_zookeeper {
    service { 'hbase-zookeeper':
      ensure => running,
      enable => true,
    }
  }

  if member($hbase::slaves, $::fqdn) {
    service { 'hbase-regionserver':
      ensure => running,
      enable => true,
    }
  }
}
