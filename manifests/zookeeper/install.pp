# = Class hbase::zookeeper::config
#
# Installs internal HBase zookeeper (deprecated, always use external).
#
class hbase::zookeeper::install {
  include stdlib

  if !$hbase::external_zookeeper {
    contain hbase::common::postinstall

    if !$hbase::packages['zookeeper'] {
      fail('hbase zookepper not supported on this platform, external zookeeper needed')
    }

    ensure_packages($hbase::packages['zookeeper'])
    Package[$hbase::packages['zookeeper']] -> Class['hbase::common::postinstall']
  }
}
