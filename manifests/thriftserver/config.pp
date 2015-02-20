class hbase::thriftserver::config {
  contain hbase::common::config
  contain hbase::common::daemons::config

  if $hbase::features["restarts"] {
    $cron_ensure = 'present'
  } else {
    $cron_ensure = 'absent'
  }
  file { '/etc/cron.d/hbase-thriftserver-restarts':
    ensure  => $cron_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    alias   => 'hbase-thriftserver-cron',
    content => template('hbase/cron-thriftserver-restart.erb'),
  }
}
