# = Class hbase::master::config
#
# Configuration for HBase master.
#
class hbase::master::config {
  contain hbase::common::config
  contain hbase::common::daemons::config

  if $hbase::features["restarts"] {
    $cron_ensure = 'present'
  } else {
    $cron_ensure = 'absent'
  }
  file { '/etc/cron.d/hbase-master-restarts':
    ensure  => $cron_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    alias   => 'hbase-master-cron',
    content => template('hbase/cron-master-restart.erb'),
  }
}
