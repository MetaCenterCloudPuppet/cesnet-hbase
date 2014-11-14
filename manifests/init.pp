# == Class: hbase
#
# HBase Cluster setup.
#
# Before installing with Hadoop:
# - create hbase user on Hadoop HDFS Name Node
# - create /hbase HDFS directory:
#   hdfs dfs -mkdir /hbase
#   hdfs dfs -chown hbase:hbase /hbase
# - if enabled https, hbase needs access to http secret file:
#   setfacl -m u:hbase:r /etc/hadoop/security/http-auth-signature-secret
#
# === Parameters
#
# [*hdfs_hostname*] (localhost)
#   Main node of Hadoop (HDFS Name Node).
#
# [*master_hostname*] (undef)
#   HBase master node.
#
# [*zookeeper_hostnames*] required
#   Zookeepers to use. May be ["localhost"] in non-cluster mode.
#
# [*external_zookeeper*] (false)
#   Don't launch HBase Zookeeper.
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
  $zookeeper_hostnames,
  $external_zookeeper = $hbase::params::external_zookeeper,
  $slaves = [],
  $realm,
  $properties = $hbase::params::properties,
  $descriptions = $hbase::params::descriptions,
) inherits hbase::params {
  include stdlib

  if $hbase::realm {
    $sec_properties = {
      'hbase.security.authentication' => 'kerberos',
      'hbase.master.keytab.file' => '/etc/security/keytab/hbase.service.keytab',
      'hbase.master.kerberos.principal' => "hbase/_HOST@${hbase::realm}",
      'hbase.regionserver.keytab.file' => '/etc/security/keytab/hbase.service.keytab',
      'hbase.regionserver.kerberos.principal' => "hbase/_HOST@${hbase::realm}",
      'hbase.security.authorization' => true,
      'hbase.coprocessor.region.classes' => 'org.apache.hadoop.hbase.security.access.AccessController,org.apache.hadoop.hbase.security.token.TokenProvider',
      'hbase.coprocessor.master.classes' => 'org.apache.hadoop.hbase.security.access.AccessController',
      'hbase.coprocessor.regionserver.classes' => 'org.apache.hadoop.hbase.security.access.AccessController',
      'hbase.security.exec.permissions.checks' => true,
      'hbase.rpc.protection' => 'auth-conf',
    }
  }
  $all_descriptions = {
    'hbase.security.authentication' => 'simple, kerberos',
    'hbase.coprocessor.region.classes' =>  'for enabling full security and ACLs',
    'hbase.rpc.protection' => 'auth-conf, private (10% performance penalty)',
  }

  $props = merge($sec_properties, $properties)
  $descs = merge($all_descriptions, $descriptions)

  class { 'hbase::install': } ->
  class { 'hbase::config': } ~>
  class { 'hbase::service': } ->
  Class['hbase']

}
