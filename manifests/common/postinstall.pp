# == Class hbase::common::postinstall
#
# Preparation steps after installation. It switches hbase-conf alternative, if enabled.
#
class hbase::common::postinstall {
  ::hadoop_lib::postinstall{ 'hbase':
    alternatives => $::hbase::alternatives,
  }
}
