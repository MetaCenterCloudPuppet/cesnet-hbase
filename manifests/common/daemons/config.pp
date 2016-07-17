# = Class hbase::common::daemons::config
#
# Configuration needed for all HBase daemons.
#
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
    $backup_hostnames = $hbase::backup_hostnames
    $rest_hostnames = $hbase::rest_hostnames
    $thrift_hostnames = $hbase::thrift_hostnames
    $slaves = $hbase::slaves
    file { '/usr/local/sbin/hbmanager':
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      alias   => 'hbmanager',
      content => template('hbase/hbmanager.erb'),
    }
  }

  if $hbase::https {
    file { "${hbase::hbase_homedir}/hadoop.keytab":
      owner  => 'hbase',
      group  => 'hbase',
      mode   => '0600',
      source => '/etc/security/keytab/http.service.keytab',
    }
    file { "${hbase::hbase_homedir}/http-auth-signature-secret":
      owner  => 'hbase',
      group  => 'hbase',
      mode   => '0600',
      source => '/etc/security/http-auth-signature-secret',
    }
    file { "${hbase::hbase_homedir}/keystore.server":
      owner  => 'hbase',
      group  => 'hbase',
      mode   => '0600',
      source => $hbase::https_keystore,
    }

    if $hbase::acl {
      exec { 'setfacl-ssl-hbase':
        command => "setfacl -m u:hbase:r ${hbase::configdir_hadoop}/ssl-server.xml ${hbase::configdir_hadoop}/ssl-client.xml && touch ${hbase::hbase_homedir}/.puppet-ssl-facl",
        path    => '/sbin:/usr/sbin:/bin:/usr/bin',
        creates => "${hbase::hbase_homedir}/.puppet-ssl-facl",
        require => [
          File["${hbase::configdir_hadoop}/ssl-client.xml"],
          File["${hbase::configdir_hadoop}/ssl-server.xml"],
        ],
      }

      # ssl-client.xml and ssl-server.xml
      Class['hadoop::common::config'] -> Exec['setfacl-ssl-hbase']
    }
  }
}
