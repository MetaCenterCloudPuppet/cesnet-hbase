# == Class hbase::hdfs
#
# HBase initialization on HDFS.
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
  case $::osfamily {
    default: {
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

  $touchfile = 'hbase-dir-created'
  hadoop::kinit { 'hbase-kinit':
    touchfile => $touchfile,
  }
  ->
  hadoop::mkdir { '/hbase':
    owner     => 'hbase',
    group     => 'hbase',
    touchfile => $touchfile,
  }
  ->
  hadoop::kdestroy { 'hbase-kdestroy':
    touchfile => $touchfile,
    touch     => true,
  }
}
