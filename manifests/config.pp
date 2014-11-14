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

  file { '/etc/hbase/regionservers':
    owner   => 'root',
    group   => 'root',
    alias   => 'regionservers',
    content => template('hbase/regionservers.erb'),
  }

  if $hbase::realm {
    file { '/etc/security/keytab/hbase.service.keytab':
      owner => 'hbase',
      group => 'hbase',
      mode  => '0400',
      alias => 'hbase.service.keytab',
    }

    if $hbase::features["restarts"] {
      if $master_hostname == $::fqdn {
        file { "/etc/cron.d/hbase-master-restarts":
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          alias   => "hbase-master-cron",
          content => template("hbase/cron-master-restart.erb"),
        }
      }
      if member($slaves, $::fqdn) {
        file { "/etc/cron.d/hbase-regionserver-restarts":
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          alias   => "hbase-regionserver-cron",
          content => template("hbase/cron-regionserver-restart.erb"),
        }
      }
    }
  }
}
