class hbase::master::service {
  service { $hbase::daemons['master']:
    ensure => running,
    enable => true,
  }
}
