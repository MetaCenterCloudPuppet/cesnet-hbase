# == Class hbase::hdfs
#
# Actions necessary to launch on HDFS namenode. Creates hbase user, if needed. Creates directory structure on HDFS for HBase. It needs to be called after Hadoop HDFS is working (its namenode and proper number of datanodes) and before HBase service startup.
#
# This class is needed to be launched on HDFS namenode. With some limitations it can be launched on any Hadoop node (user hbase created or hbase installed on namenode, kerberos ticket available on the local node).
#
class hbase::hdfs {
  # create user/group if needed (we don't need to install hbase just for user, unless it is colocated with the master)
  group { 'hbase':
    ensure => present,
    system => true,
  }
  case "${::osfamily}" {
    'RedHat': {
      user { 'hbase':
        ensure     => present,
        system     => true,
        comment    => 'Apache HBase',
        gid        => 'hbase',
        home       => '/var/lib/hbase',
        managehome => true,
        password   => '!!',
        shell      => '/sbin/nologin',
      }
    }
    'Debian': {
      user { 'hbase':
        ensure     => present,
        system     => true,
        comment    => 'HBase User',
        gid        => 'hbase',
        home       => '/var/lib/hbase',
        managehome => true,
        password   => '!!',
        shell      => '/bin/bash',
      }
    }
  }
  Group['hbase'] -> User['hbase']

  $realm = $hbase::realm
  $env = [ 'KRB5CCNAME=FILE:/tmp/krb5cc_nn_puppet' ]
  $path = '/sbin:/usr/sbin:/bin:/usr/bin'
  $touchfile = '/var/lib/hadoop-hdfs/.puppet-hbase-dir-created'

  # better to destroy the ticket (it may be owned by root),
  # destroy it only when needed though
  exec { 'hbase-kdestroy-old':
    command     => 'kdestroy',
    path        => $path,
    environment => $env,
    onlyif      => "test -n \"${realm}\"",
    creates     => $touchfile,
    require    => User['hbase'],
  }
  ->
  exec { 'hbase-kinit':
    command     => "kinit -k -t /etc/security/keytab/nn.service.keytab nn/${::fqdn}@${realm}",
    path        => $path,
    environment => $env,
    onlyif      => "test -n \"${realm}\"",
    user        => 'hdfs',
    creates     => $touchfile,
  }
  ->
  exec { 'hbase-dir':
    command     => 'hdfs dfs -mkdir /hbase',
    path        => $path,
    environment => $env,
    unless      => 'hdfs dfs -test -d /hbase',
    user        => 'hdfs',
    creates     => $touchfile,
  }
  ->
  exec { 'hbase-chown':
    command     => "hdfs dfs -chown hbase:hbase /hbase && touch ${touchfile}",
    path        => $path,
    environment => $env,
    user        => 'hdfs',
    creates     => $touchfile,
  }
  ->
  exec { 'hbase-kdestroy':
    command     => 'kdestroy',
    path        => $path,
    environment => $env,
    user        => 'hdfs',
    creates     => $touchfile,
  }
}
