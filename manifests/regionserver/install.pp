# = Class hbase::regionserver::config
#
# Installs HBase worker.
#
class hbase::regionserver::install {
  include stdlib
  contain hbase::common::postinstall

  ensure_packages($hbase::packages['regionserver'])
  Package[$hbase::packages['regionserver']] -> Class['hbase::common::postinstall']
}
