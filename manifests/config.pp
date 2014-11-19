# == Class hbase::config
#
# This class is called from hbase
#
class hbase::config {

  # general configuration
  if $hbase::daemons or $hbase::frontend {
    file { '/etc/hbase/hbase-site.xml':
      owner   => 'root',
      group   => 'root',
      alias   => 'hbase-site.xml',
      content => template('hbase/hbase-site.xml.erb'),
    }

    file { '/etc/hbase/regionservers':
      owner   => 'root',
      group   => 'root',
      alias   => 'regionservers',
      content => template('hbase/regionservers.erb'),
    }
  }

  # configuration needed for daemons
  if $hbase::daemons {

    file { '/etc/security/limits.d/90-hbase.conf':
      owner  => 'root',
      group  => 'root',
      alias  => 'limits.conf',
      source => 'puppet:///modules/hbase/limits.conf',
    }

    if $hbase::realm {
      file { '/etc/security/keytab/hbase.service.keytab':
        owner => 'hbase',
        group => 'hbase',
        mode  => '0400',
        alias => 'hbase.service.keytab',
      }

      if $hbase::features["restarts"] {
        if $hbase::master_hostname == $::fqdn {
          file { '/etc/cron.d/hbase-master-restarts':
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            alias   => 'hbase-master-cron',
            content => template('hbase/cron-master-restart.erb'),
          }
        }
        if member($hbase::slaves, $::fqdn) {
          file { '/etc/cron.d/hbase-regionserver-restarts':
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            alias   => 'hbase-regionserver-cron',
            content => template('hbase/cron-regionserver-restart.erb'),
          }
        }
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
}
