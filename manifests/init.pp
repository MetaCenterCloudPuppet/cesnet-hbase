# == Class: hbase
#
# HBase Cluster setup.
#
# === Parameters
#
# [*hdfs_hostname*] (localhost)
#   Main node of Hadoop (HDFS Name Node).
#
# [*master_hostname*] (undef)
#   HBase master node.
#
# [*slaves*] ([])
#   HBase regionserver nodes.
#
# [*realm*] required
#   Kerberos realm, or empty string to disable security.
#
# [*properties*]
#
# [*descriptions*]
#
class hbase (
  $package_name = $hbase::params::package_name,
  $service_name = $hbase::params::service_name,

  $hdfs_hostname = $hbase::params::hdfs_hostname,
  $master_hostname = undef,
  $slaves = [],
  $realm,
  $properties = $hbase::params::properties,
  $descriptions = $hbase::params::descriptions,
) inherits hbase::params {
  include stdlib

  if $hbase::realm {
    $sec_properties = {
      'hbase.security.authentication' => 'kerberos',
      'hbase.master.keytab.file' => '/etc/security/keytabs/hbase.service.keytab',
      'hbase.master.kerberos.principal' => "hbase/_HOST@${hbase::realm}",
      'hbase.regionserver.keytab.file' => '/etc/security/keytabs/hbase.service.keytab',
      'hbase.regionserver.kerberos.principal' => "hbase/_HOST@${hbase::realm}",
    }
  }
  $all_descriptions = {
    'hbase.security.authentication' => 'simple, kerberos',
  }

  $props = merge($sec_properties, $properties)
  $descs = merge($all_descriptions, $descriptions)

  class { 'hbase::install': } ->
  class { 'hbase::config': } ~>
  class { 'hbase::service': } ->
  Class['hbase']

}
