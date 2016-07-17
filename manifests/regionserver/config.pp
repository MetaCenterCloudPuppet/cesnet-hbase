# = Class hbase::regionserver::config
#
# Configuration for HBase worker.
#
class hbase::regionserver::config {
  contain hbase::common::config
  contain hbase::common::daemons::config

  if $hbase::features["restarts"] {
    $cron_ensure = 'present'
  } else {
    $cron_ensure = 'absent'
  }
  file { '/etc/cron.d/hbase-regionserver-restarts':
    ensure  => $cron_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    alias   => 'hbase-regionserver-cron',
    content => template('hbase/cron-regionserver-restart.erb'),
  }
}
