# == Class hbase::config
#
# This class is called from hbase
#
class hbase::config {
  file { '/etc/security/limits.d/90-hbase.conf':
    owner  => 'root',
    group  => 'root',
    alias  => 'limits.conf',
    source => 'puppet:///modules/hbase/limits.conf',
  }

  file { '/etc/hbase/hbase-site.xml':
    owner   => 'root',
    group   => 'root',
    alias   => 'hbase-site.xml',
    content => template('hbase/hbase-site.xml.erb'),
  }

  if $hbase::realm {
    file { '/etc/security/keytab/hbase.service.keytab':
      owner => 'hbase',
      group => 'hbase',
      mode  => '0400',
      alias => 'hbase.service.keytab',
    }
  }
}
