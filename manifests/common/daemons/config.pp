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

  if $hbase::https {
    file { "${hbase::hbase_homedir}/hadoop.keytab":
      owner  => 'hbase',
      group  => 'hbase',
      mode   => '0640',
      source => '/etc/security/keytab/http.service.keytab',
    }
    file { "${hbase::hbase_homedir}/http-auth-signature-secret":
      owner  => 'hbase',
      group  => 'hbase',
      mode   => '0640',
      source => '/etc/security/http-auth-signature-secret',
    }
#    file { "${hbase::hbase_homedir}/keystore.server":
#      owner  => 'hbase',
#      group  => 'hbase',
#      mode   => '0640',
#      source => $hbase::https_keystore,
#    }
  }
}
