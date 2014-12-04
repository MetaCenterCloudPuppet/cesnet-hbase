class hbase::regionserver::service {
  service { $hbase::daemons['regionserver']:
    ensure => running,
    enable => true,
  }
}
