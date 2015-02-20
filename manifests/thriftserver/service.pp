class hbase::thriftserver::service {
  service { $hbase::daemons['thriftserver']:
    ensure => running,
    enable => true,
  }
}
