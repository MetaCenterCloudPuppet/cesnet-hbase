class hbase::restserver::service {
  service { $hbase::daemons['restserver']:
    ensure => running,
    enable => true,
  }
}
