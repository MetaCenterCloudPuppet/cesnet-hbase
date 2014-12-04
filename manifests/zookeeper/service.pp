class hbase::zookeeper::service {
  service { $hbase::daemons['zookeeper']:
    ensure => running,
    enable => true,
  }
}
