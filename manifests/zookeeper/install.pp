class hbase::zookeeper::install {
  include stdlib

  if !$hbase::packages['zookeeper'] and !$hbase::external_zookeeper{
    fail("hbase zookepper not supported on this platform, external zookeeper needed")
  }
  ensure_packages($hbase::packages['zookeeper'])
}
