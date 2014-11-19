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

  # setup directory layout on HDFS namenode
  if $hbase::hdfs_hostname == $::fqdn {
    $realm = $hbase::realm
    $env = [ 'KRB5CCNAME=FILE:/tmp/krb5cc_nn_puppet' ]
    $path = '/sbin:/usr/sbin:/bin:/usr/bin'
    $touchfile = '/var/lib/hadoop-hdfs/.puppet-hbase-dir-created'

    # create user/group if needed (we don't need to install hbase just for user, unless it is colocated with the master)
    group { 'hbase':
      ensure => present,
      system => true,
    }
    user { 'hbase':
      ensure     => present,
      system     => true,
      comment    => 'Apache HBase',
      gid        => 'hbase',
      home       => '/var/lib/hbase',
      managehome => true,
      password   => '!!',
      shell      => '/sbin/nologin',
      require    => Group['hbase'],
    }
    ->
    # destroy it only when needed though
    exec { 'hbase-kdestroy':
      command     => 'kdestroy',
      path        => $path,
      environment => $env,
      onlyif      => "test -n \"${realm}\"",
      creates     => $touchfile,
    }
    ->
    exec { 'hbase-kinit':
      command     => "runuser hdfs -s /bin/bash /bin/bash -c \"kinit -k nn/${::fqdn}@${realm} -t /etc/security/keytab/nn.service.keytab\"",
      path        => $path,
      environment => $env,
      onlyif      => "test -n \"${realm}\"",
      creates     => $touchfile,
    }
    ->
    exec { 'hbase-dir':
      command     => 'runuser hdfs -s /bin/bash /bin/bash -c "hdfs dfs -mkdir /hbase"',
      path        => $path,
      environment => $env,
      unless      => 'runuser hdfs -s /bin/bash /bin/bash -c "hdfs dfs -test -d /hbase"',
      creates     => $touchfile,
    }
    ->
    exec { 'hbase-chown':
      command     => "runuser hdfs -s /bin/bash /bin/bash -c \"hdfs dfs -chown hbase:hbase /hbase\" && touch ${touchfile}",
      path        => $path,
      environment => $env,
      creates     => $touchfile,
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
