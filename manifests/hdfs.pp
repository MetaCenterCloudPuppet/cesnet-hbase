# == Class hbase::hdfs
#
# HBase initialization on HDFS.
#
# Actions necessary to launch on HDFS namenode. Creates hbase user, if needed. Creates directory structure on HDFS for HBase. It needs to be called after Hadoop HDFS is working (its namenode and proper number of datanodes) and before HBase service startup.
#
# This class is needed to be launched on HDFS namenode. With some limitations it can be launched on any Hadoop node (user hbase created or hbase installed on namenode, kerberos ticket available on the local node).
#
class hbase::hdfs {
  include ::hbase::user

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
