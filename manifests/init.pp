# == Class: hbase
#
# HBase Cluster setup.
#
# Installation notes:
#
# 1) Hadoop cluser needs to be already completely deployed (HDFS namenode and datanodes)
#
# 2) hbase class needs to be launch also on HDFS namenode,
#    if not:
#  - create hbase user on Hadoop HDFS Name Node (or install HBase)
#  - create /hbase HDFS directory:
#      hdfs dfs -mkdir /hbase
#      hdfs dfs -chown hbase:hbase /hbase
#
# 3) if enabled https in Hadoop, hbase needs access to http secret file and Kerberos keyfile ==> enable https also in hbase
#
# Web UI: ports 60010, 60030, https is not supported
#
# Any changes will be done only on these hostnames:
# * master_hostname
# * zookeeper_hostnames (if external_zookeeper is false)
# * slaves
# * frontends
# * (hdfs_hostname: only 'kinit' and 'hdfs dfs' commands)
#
# === Parameters
#
# [*hdfs_hostname*] required
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
# [*frontends*] ([])
#   Array of frontend hostnames. Package and configuration is needed on frontends.
#
# [*realm*] required
#   Kerberos realm, or empty string to disable security.
#   To enable security, there are required:
#   * configured Kerberos (/etc/krb5.conf, /etc/krb5.keytab)
#   * /etc/security/keytab/hbase.service.keytab
#   * enabled security on HDFS
#   * enabled security on zookeeper, if external
#
# [*properties*]
#
# [*descriptions*]
#
# [*features*]
#   * restarts
#   * hbmanager
#
# [*https*] undef
#
class hbase (
  $package_name = $hbase::params::package_name,
  $service_name = $hbase::params::service_name,

  $hdfs_hostname,
  $master_hostname = undef,
  $zookeeper_hostnames,
  $external_zookeeper = $hbase::params::external_zookeeper,
  $slaves = [],
  $frontends = [],
  $realm,
  $properties = undef,
  $descriptions = undef,
  $features = [],
  $https = undef,
  $perform = $hbase::params::perform,
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
      'hbase.coprocessor.master.classes' => 'org.apache.hadoop.hbase.security.access.AccessController',
      'hbase.coprocessor.region.classes' => 'org.apache.hadoop.hbase.security.token.TokenProvider,org.apache.hadoop.hbase.security.access.AccessController',
      'hbase.security.exec.permissions.checks' => true,
      'hbase.rpc.protection' => 'auth-conf',
      'hbase.rpc.engine' => 'org.apache.hadoop.hbase.ipc.SecureRpcEngine',
    }
  }
  $all_descriptions = {
    'hbase.security.authentication' => 'simple, kerberos',
    'hbase.coprocessor.region.classes' =>  'for enabling full security and ACLs',
    'hbase.rpc.protection' => 'auth-conf, private (10% performance penalty)',
  }

  $props = merge($hbase::params::properties, $sec_properties, $properties)
  $descs = merge($hbase::params::descriptions, $all_descriptions, $descriptions)

  if ($hbase::perform) {
    include hbase::install
    include hbase::config
    include hbase::service

    Class['hbase::install'] ->
    Class['hbase::config'] ~>
    Class['hbase::service'] ->
    Class['hbase']
  }
}
