class hbase::zookeeper::install {
  include stdlib

  if !$hbase::external_zookeeper {
    if !$hbase::packages['zookeeper'] {
      fail("hbase zookepper not supported on this platform, external zookeeper needed")
    }

    ensure_packages($hbase::packages['zookeeper'])
  }
}
