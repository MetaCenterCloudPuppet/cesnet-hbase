# = Class hbase::frontend::config
#
# Configuration for HBase client.
#
class hbase::frontend::config {
  contain hbase::common::config

  if $hbase::external_zookeeper {
    contain hbase::common::keytab
  }

  file {'/var/lib/hbase/local':
    ensure => 'directory',
    owner  => 'hbase',
    group  => 'hbase',
  }
  ->
  file {'/var/lib/hbase/local/jars':
    ensure => 'directory',
    owner  => 'hbase',
    group  => 'hbase',
  }
}
