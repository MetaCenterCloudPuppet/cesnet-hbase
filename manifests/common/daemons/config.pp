class hbase::common::daemons::config {
  contain hbase::common::keytab

  if "${::osfamily}/${::operatingsystem}" == 'RedHat/Fedora' {
    file { '/etc/security/limits.d/90-hbase.conf':
      owner  => 'root',
      group  => 'root',
      alias  => 'limits.conf',
      source => 'puppet:///modules/hbase/limits.conf',
    }
  }

  if $hbase::features["hbmanager"] {
    file { '/usr/local/sbin/hbmanager':
      mode    => '0755',
      alias   => 'hbmanager',
      content => template('hbase/hbmanager.erb'),
    }
  }
}
